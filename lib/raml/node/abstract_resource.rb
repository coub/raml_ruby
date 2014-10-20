module Raml
  class AbstractResource < PropertiesNode
    inherit_class_attributes

    include Documentable
    include Global
    include Merge
    include Parent
    include Validation

    # @!attribute [r] base_uri_parameters
    #   @return [Hash<String, Raml::Parameter::BaseUriParameter>] the base URI parameters, keyed
    #     by the parameter name. 

    # @!attribute [r] uri_parameters
    #   @return [Hash<String, Raml::Parameter::UriParameter>] the URI parameters, keyed
    #     by the parameter name. 

    # @!attribute [r] methods
    #   @return [Hash<String, Raml::Method>] the methods, keyed by the method name.

    # @!attribute [r] traits
    #   @return [Array<Raml::Trait, Raml::TraitReference>] the traits and trait references.

    non_scalar_property :uri_parameters, :base_uri_parameters, :is, :type, :secured_by,
      *Raml::Method::NAMES, *Raml::Method::NAMES.map { |m| "#{m}?" }

    children_by :methods            , :name, Raml::Method
    children_by :base_uri_parameters, :name, Parameter::BaseUriParameter, true
    children_by :uri_parameters     , :name, Parameter::UriParameter    , true

    children_of :traits, [ Raml::Trait, Raml::TraitReference ]

    # @private
    def apply_resource_type
      if type
        # We clone the resource as it currently is; apply the resource type to the
        # resource, so that optional properties are correctly evaluated; then we
        # apply the cloned resource with the initial state, so that scalar properties
        # in the resource override the ones in the resource type.
        cloned_self = self.clone
        merge instantiate_resource_type
        merge cloned_self
      end
    end

    # @private
    def merge(other)
      raise MergeError, "Trying to merge #{other.class} into Resource." unless other.is_a? ResourceType::Instance or other.is_a? Resource

      super

      merge_properties other, :methods
      merge_properties other, :base_uri_parameters
      merge_properties other, :uri_parameters

      # merge traits. insert the non-matching ones in the front, so they have the least priority.
      match, no_match = other.traits.partition do |other_trait|
        if other_trait.is_a? Trait
          false
        else # TraitReference
          self.traits.any? do |self_trait|
            self_trait.is_a?(TraitReference)                && 
            self_trait.name       == other_trait.name       && 
            self_trait.parameters == other_trait.parameters
          end
        end
      end
      @children.unshift(*no_match)

      self
    end

    # Returns the resource's full path.
    # @return [String] the resource's full path.
    def resource_path
      @parent.resource_path + self.name
    end


    # Returns the last non regex resource name
    # @return [String] the last non request resource name
    def resource_path_name
      resource_path.split('/').reverse.detect do |pathPart|
        !pathPart.match(/[{}]/)
      end || ""
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

      define_method("parse_#{method}?") do |value|
        Method.new "#{method}?", value, self
      end
    end

    def parse_type(value)
      validate_property :type, value, [ Hash, String ]

      if value.is_a? Hash
        if value.keys.size == 1 and resource_type_declarations.include? value.keys.first
          raise InvalidProperty, 'type property with map of resource type name but params are not a map' unless 
            value.values[0].is_a? Hash
          ResourceTypeReference.new( *value.first, self )
        else
          ResourceType.new '_', value, self
        end
      else
        raise UnknownResourceTypeReference, "#{value} referenced in resource but not found in resource types declaration." unless
          resource_type_declarations.include? value
        ResourceTypeReference.new value, self
      end
    end

    def parse_secured_by(data)
      # XXX ignored for now
      []
    end

    def instantiate_resource_type
      reserved_params = {
        'resourcePath'     => resource_path,
        'resourcePathName' => resource_path_name
      }
      if ResourceTypeReference === type
        resource_type_declarations[type.name].instantiate type.parameters.merge reserved_params
      else
        type.instantiate reserved_params
      end
    end
  end
end
