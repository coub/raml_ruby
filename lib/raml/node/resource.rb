module Raml
  class Resource < AbstractResource
    inherit_class_attributes

    regexp_property( /\A\//, ->(key,value) { Resource.new key, value, self } )

    # @!attribute [r] resources
    #   @return [Hash<String, Raml::Resource>] the nested resources, keyed by the resource relative path.

    children_by :resources, :name, Resource

    # @private
    def apply_resource_type
      super
      resources.values.each(&:apply_resource_type)
    end

    # @private
    def apply_traits
      methods.values.each(&:apply_traits)
      resources.values.each(&:apply_traits)
    end
  end
end
