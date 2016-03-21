module Raml
  class ResourceType < Template
    class Instance < AbstractResource
      inherit_class_attributes

      # @!attribute [rw] usage
      #   @return [String,nil] how the resource type should be used.
      scalar_property :usage
    end

    # Instantiate a new resource type with the given parameters.
    # @param params [Hash] the parameters to interpolate in the resource type.
    # @return [Raml::ResourceType::Instance] the instantiated resouce type.
    def instantiate(params)
      instance = Instance.new( *interpolate(params), @parent )
      instance.apply_resource_type
      instance
    end
  end
end
