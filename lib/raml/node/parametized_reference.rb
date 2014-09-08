module Raml
  class ParametizedReference < Reference
    attr_accessor :parameters

    def initialize(name, parameters={}, parent)
    	@name 			= name
    	@parameters = parameters
    	@parent     = parent
    end
  end
end