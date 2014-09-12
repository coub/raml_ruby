module Raml
  class ParametizedReference < Reference
    attr_accessor :parameters

    def initialize(name, parameters={}, parent)
    	super name, parent
    	@parameters = parameters
    end
  end
end