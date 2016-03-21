module Raml
  class Trait < Template
    class Instance < AbstractMethod
      inherit_class_attributes

      # @!attribute [rw] usage
      #   @return [String,nil] how the trait should be used.
      scalar_property :usage
    end

    # Instantiate a new trait with the given parameters.
    # @param params [Hash] the parameters to interpolate in the trait.
    # @return [Raml::Trait::Instance] the instantiated trait.
    def instantiate(params)
      Instance.new( *interpolate(params), @parent )
    end
  end
end
