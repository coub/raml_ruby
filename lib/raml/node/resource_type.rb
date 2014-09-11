module Raml
  class ResourceType < Template
  	class Instance < AbstractResource
	    inherit_class_attributes

	    include Optional

  		scalar_property :usage
  	end

  	def instantiate(params)
  		Instance.new( *interpolate(params), @parent )
  	end
  end
end
