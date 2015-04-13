module Raml
  module Documentable
    # @!attribute [rw] display_name
    #   @return [String, nil] the node's display name.

    # @!attribute [rw] description
    #   @return [String, nil] the node's description.

    # @private

    private

    def self.included(base)
      base.instance_eval do
        scalar_property :display_name, :description
      end
    end

    def validate_display_name
      raise InvalidProperty, "displayName property must be a string." unless display_name.is_a? String
    end

    def validate_description
      raise InvalidProperty, "description property must be a string." unless description.is_a? String
    end
  end
end
