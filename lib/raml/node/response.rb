module Raml
  class Response < PropertiesNode
    inherit_class_attributes

    include Documentable
    include Global
    include Merge
    include Parent
    include Validation
    include Bodies
    include Headers

    def initialize(name, properties, parent)
      super
      @name = name.to_i
    end

    # @private
    def merge(other)
      raise MergeError, "Response status codes don't match." if name != other.name

      super

      merge_properties other, :headers
      merge_properties other, :bodies

      self
    end
  end
end
