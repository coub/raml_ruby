module Raml
  class ResourceType < Template
  	class Instance < AbstractResource
	    inherit_class_attributes

  		scalar_property :usage
  	end

  	def instantiate(params)
  		instance = Instance.new( *interpolate(params), @parent )
  		instance.apply_resource_type
  		instance
  	end
  end
end
