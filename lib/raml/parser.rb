require 'yaml'

module Raml
  class Parser
    def initialize(data)
      @data = YAML.load(data)
      self
    end

    def parse
      @root = Root.new(@data)

      @root
    end
  end
end
