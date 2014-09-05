module Raml
  class ResourceTypeReference
    attr_accessor :name, :parameters

    def initialize(name, parameters={})
    	self.name 			= name
    	self.parameters = parameters
    end
  end
end