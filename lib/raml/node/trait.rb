module Raml
  class Trait < Template
  	class Instance < AbstractMethod
  		inherit_class_attributes

  		scalar_property :usage
  	end

  	def instantiate(params)
  		Instance.new( *interpolate(params), @parent )
  	end
  end
end