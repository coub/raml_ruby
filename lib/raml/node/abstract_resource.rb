module Raml
  class AbstractResource < PropertiesNode
    inherit_class_attributes

    include Documentable
    include Global
    include Parent
    include Validation

    non_scalar_property :uri_parameters, :base_uri_parameters, :is, *Raml::Method::NAMES

    children_by :methods            , :name, Raml::Method
    children_by :base_uri_parameters, :name, Parameter::BaseUriParameter
    children_by :uri_parameters     , :name, Parameter::UriParameter

    children_of :traits, [ Trait, TraitReference ]

    def document
      doc = ''
      doc << "**#{display_name || name}**\n"
      doc << "#{description}\n" if description
      doc << children.map(&:document).compact.join('\n')
      doc
    end

    def resource_path
      @parent.resource_path + self.name
    end

    def apply_traits
      methods.values.each(&:apply_traits)
    end

    private
    
    def validate_parent
      raise InvalidParent, "Parent of resource cannot be nil." if @parent.nil?
    end

    def parse_uri_parameters(value)
      validate_hash :uri_parameters, value, String, Hash
      value.map { |uname, udata| Parameter::UriParameter.new uname, udata, self }
    end

    def parse_base_uri_parameters(value)
      validate_hash :base_uri_parameters, value, String, Hash
      
      raise InvalidProperty, 'baseUriParameters property can\'t contain reserved "version" parameter' if
        value.include? 'version'

      value.map { |bname, bdata| Parameter::BaseUriParameter.new bname, bdata, self }
    end

    def parse_is(value)
      validate_array :is, value, [String, Hash]

      value.map do |trait|
        if trait.is_a? Hash
          if trait.keys.size == 1 and trait_declarations.include? trait.keys.first
            raise InvalidProperty, 'is property with map of trait name but params are not a map' unless 
              trait.values[0].is_a? Hash
            TraitReference.new( *trait.first, self )
          else
            Trait.new '_', trait, self
          end
        else
          raise UnknownTraitReference, "#{trait} referenced in resource but not found in traits declaration." unless
            trait_declarations.include? trait
          TraitReference.new trait, self
        end
      end
    end

    Raml::Method::NAMES.each do |method|
      define_method("parse_#{method}") do |value|
        Method.new method, value, self
      end
    end
  end
end
