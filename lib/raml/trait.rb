module Raml
  class Trait < Template
  	class Instance < AbstractMethod
  		attr_accessor :usage
  	end

  	def instantiate(params)
  		Instance.new( *interpolate(params), @parent )
  	end
  end
end