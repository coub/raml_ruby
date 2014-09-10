require 'active_support'
require 'active_support/core_ext/class/attribute'

module Raml
  class Node
  end

  class ValueNode < Node
    attr_accessor :name, :value, :parent

    def initialize(name, value, parent)
      @name   = name
      @value  = value
      @parent = parent

      validate_value if respond_to? :validate_value, true
    end
  end

  class PropertiesNode < Node
    class_attribute  :scalar_properties, :non_scalar_properties, :_regexp_property
    self.scalar_properties     = []
    self.non_scalar_properties = []
    self._regexp_property      = nil

    class << self
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

    def scalar_properties    ; self.class.scalar_properties    ; end
    def non_scalar_properties; self.class.non_scalar_properties; end
    def _regexp_property     ; self.class._regexp_property     ; end 

    attr_reader :name, :parent

    def initialize(name, properties, parent)
      @name       = name
      @parent     = parent
      @children ||= []
      parse_and_validate_props properties
    end

    private

    def parse_and_validate_props(properties)
      maybe_exec :validate_name
      maybe_exec :validate_parent

      properties.each do |prop_name, prop_value|
        prop_name       = prop_name.to_s
        under_prop_name = Raml.underscore prop_name

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
          raise UnknownProperty, "#{prop_name} is an unknown property."
        end
      end

      validate if respond_to? :validate, true
    end

    def maybe_exec(method, *args)
      send(method,*args) if respond_to? method, true
    end
  end
end