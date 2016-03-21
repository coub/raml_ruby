module Raml
  class SecurityScheme < Template
    class Instance < PropertiesNode
      inherit_class_attributes

      include Validation

      # @!attribute [rw] description
      #   @return [String,nil] how the description of the security scheme.
      scalar_property :description

      # @!attribute [rw] type
      #   @return [String,nil] describes the type of the security scheme.
      scalar_property :type

      # @!attribute [r] described_by
      #   @return [Hash<String, Raml::Trait>] the trait-like description of the
      #                                       security scheme.

      # @!attribute [r] settings
      #   @return [Hash<String, Any] the settings for the security scheme

      non_scalar_property :described_by, :settings

      private

      def parse_described_by(value)
        validate_hash :described_by, value, String, Hash
        value.map { |uname, udata| Trait.new uname, udata, self }
      end

      def parse_settings(value)
        validate_hash :settings, value, String
        value
      end
    end

    # Instantiate a new resource type with the given parameters.
    # @param params [Hash] the parameters to interpolate in the resource type.
    # @return [Raml::SecurityScheme::Instance] the instantiated resouce type.
    def instantiate(params)
      instance = Instance.new( *interpolate(params), @parent )
      # instance.apply_resource_type # TODO: do we need apply_security_scheme?
      instance
    end
  end
end
