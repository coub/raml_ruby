module Raml
  class ResourceTypeReference < Node
    attr_accessor :name, :parameters

    def initialize(name, parameters={}, parent)
    	self.name 			= name
    	self.parameters = parameters
    	@parent         = parent
    end
  end
end