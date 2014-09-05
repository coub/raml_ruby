module Raml
  class ResourceType < Template
  	class Instance < AbstractResource
  		attr_accessor :usage
  	end

  	def instantiate(params)
  		Instance.new( *interpolate(params), @parent )
  	end
  end
end
