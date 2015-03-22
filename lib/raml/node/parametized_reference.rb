module Raml
  class ParametizedReference < Reference
    # @!attribute [rw] parameters
    #   @return [Hash<String,String>] parameters to interpolate when instantiating the resouce type or trait.
    attr_accessor :parameters

    # @param name [String] the resource type or trait name.
    # @param parameters [Hash<String,String>] parameters to interpolate when instantiating the resouce type or trait.
    # @param parent [Raml::Node] the parent node.
    def initialize(name, parameters={}, parent)
    	super name, parent
    	@parameters = parameters
    end
  end
end