module Raml
  class SchemaReference < Node
    attr_accessor :name

    def initialize(name, parent)
    	self.name = name
    	@parent   = parent
    end
  end
end