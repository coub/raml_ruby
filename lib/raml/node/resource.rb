module Raml
  class Resource < AbstractResource
    inherit_class_attributes

    include Merge

    non_scalar_property :type
    regexp_property( /\A\//, ->(key,value) { Resource.new key, value, self } )

    children_by :resources, :name, Resource

    child_of :type, [ ResourceType, ResourceTypeReference ]

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
      resources.values.each(&:apply_resource_type)
    end

    def apply_traits
      methods.values.each(&:apply_traits)
      resources.values.each(&:apply_traits)
    end

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

    private

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

    def instantiate_resource_type
      reserved_params = {
        'resourcePath'     => resource_path,
        'resourcePathName' => resource_path.split('/')[-1]
      }
      if ResourceTypeReference === type
        resource_type_declarations[type.name].instantiate type.parameters.merge reserved_params
      else
        type.instantiate reserved_params
      end
    end
  end
end
