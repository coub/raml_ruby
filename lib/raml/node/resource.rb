module Raml
  class Resource < AbstractResource
    inherit_class_attributes

    regexp_property( /\A\//, ->(key,value) { Resource.new key, value, self } )

    children_by :resources, :name, Resource

    self.doc_template = relative_path 'resource.slim'

    def apply_resource_type
      super
      resources.values.each(&:apply_resource_type)
    end

    def apply_traits
      methods.values.each(&:apply_traits)
      resources.values.each(&:apply_traits)
    end
  end
end
