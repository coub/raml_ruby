require 'active_support'
require 'active_support/core_ext/class/attribute'

module Raml
  class Node
    # @!attribute [r] name
    #   @return [String,Integer] the node name (e.g. resource path, header name, etc). Usually a
    #     String.  Can be an Integer for methods.
    attr_reader   :name
    # @!attribute [rw] parent
    #   @return [Raml::Node] the node's parent.
    attr_accessor :parent

    def initialize(name, parent)
      @name   = name
      @parent = parent
    end

    private

    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    def camel_case(underscored_word)
      w = underscored_word.to_s.split('_')
      (w[0...1] + w[1..-1].map(&:capitalize)).join
    end
  end

  class ValueNode < Node
    attr_accessor :value

    def initialize(name, value, parent)
      super name, parent
      @value  = value

      validate_value if respond_to? :validate_value, true
    end
  end

  class PropertiesNode < Node
    class_attribute  :scalar_properties, :non_scalar_properties, :_regexp_property
    self.scalar_properties     = []
    self.non_scalar_properties = []
    self._regexp_property      = nil

    class << self
      private
      def inherit_class_attributes
        self.scalar_properties     = self.scalar_properties.dup
        self.non_scalar_properties = self.non_scalar_properties.dup
      end

      def scalar_property(*properties)
        attr_accessor(*properties.map(&:to_sym))
        _property(scalar_properties, *properties)
      end

      def non_scalar_property(*properties)
        _property(non_scalar_properties, *properties)
      end

      def _property(type, *properties)
        properties.map(&:to_s).each { |prop| type << prop unless type.include? prop }
      end

      def regexp_property(regexp, parse)
        self._regexp_property = [ regexp, parse ]
      end
    end

    # @private
    def scalar_properties    ; self.class.scalar_properties    ; end
    # @private
    def non_scalar_properties; self.class.non_scalar_properties; end
    # @private
    def _regexp_property     ; self.class._regexp_property     ; end

    # @!attribute [rw] optional
    #   @return [Boolean] whether the property is optional. Only valid
    #     for decendant nodes a {Trait::Instance} or {ResourceType::Instance}.
    #     Indicated by a trailing "?" on the property name in the RAML source.
    attr_accessor :optional

    def initialize(name, properties, parent)
      if name.is_a? String and name.end_with? '?'
        allow_optional? parent
        name = name.dup.chomp! '?'
        @optional = true
      else
        @optional = false
      end

      super name, parent

      @children ||= []
      parse_and_validate_props properties
    end

    private

    def allow_optional?(parent)
      until parent == parent.parent or parent.is_a? Root
        return if parent.is_a? Trait::Instance or parent.is_a? ResourceType::Instance
        parent = parent.parent
      end
      raise InvalidProperty, 'Optional properties are only allowed within a trait or resource type specification.'
    end

    def parse_and_validate_props(properties)
      maybe_exec :validate_name
      maybe_exec :validate_parent

      properties.each do |prop_name, prop_value|
        prop_name       = prop_name.to_s
        under_prop_name = underscore prop_name

        if scalar_properties.include? under_prop_name
          send "#{under_prop_name}=", prop_value
          maybe_exec "validate_#{under_prop_name}"

        elsif non_scalar_properties.include? under_prop_name
          parsed = send "parse_#{under_prop_name}", prop_value
          parsed = [ parsed ] unless parsed.is_a? Array
          @children += parsed

        elsif _regexp_property and _regexp_property[0].match prop_name
          parsed = self.instance_exec(prop_name, prop_value, &_regexp_property[1])
          parsed = [ parsed ] unless parsed.is_a? Array
          @children += parsed

        else
          raise UnknownProperty, "#{prop_name} is an unknown property with value of #{prop_value}."
        end
      end

      validate if respond_to? :validate, true
    end

    def maybe_exec(method, *args)
      send(method,*args) if respond_to? method, true
    end

    def initialize_clone(other)
      super
      @children = @children.clone
      @children.map! do |child|
        child = child.clone
        child.parent = self
        child
      end
    end
  end
end