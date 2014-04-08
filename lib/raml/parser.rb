require 'yaml'

module Raml
  class Parser < Node
    def initialize(data)
      @data = YAML.load(data)
      self
    end

    def parse
      @root = Root.new

      @data.each do |key, value|
        if key.start_with?('/')
          @root.resources[key] = Resource.new(value)
        else
          @root.send("#{underscore(key)}=", value)
        end
      end

      @root
    end
  end
end
