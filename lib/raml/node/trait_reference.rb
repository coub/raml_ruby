module Raml
  class TraitReference < Node
    attr_accessor :name, :parameters

    def initialize(name, parameters={}, parent)
      self.name       = name
      self.parameters = parameters
    end
  end
end