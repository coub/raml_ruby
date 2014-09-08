module Raml
  class Reference < Node
    attr_accessor :name

    def initialize(name, parent)
    	@name   = name
    	@parent = parent
    end
  end
end