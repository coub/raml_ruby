module Raml
  module Bodies
    # @!attribute [r] bodies
    #   @return [Hash<String, Raml::Body>] the bodies, keyed by their media type.

    # XXX - need this line here to trigger Yard to generate docs for the above attribute.

    private

    def self.included(base)
      base.instance_eval do
        non_scalar_property :body
        children_by :bodies, :media_type , Body
      end
    end

    def parse_body(value)
      if value.is_a? Hash and value.keys.all? {|k| k.is_a? String and k =~ /.+\/.+/ }
        # If all keys looks like media types, its not a default media type body.
        validate_hash 'body', value, String, Hash
        value.map { |b_name, b_data| Body.new b_name, b_data, self }

      else
        # Its a default media type body.
        validate_hash 'body', value, String
        media_type = default_media_type
        raise InvalidMediaType, 'Body with no media type, but default media type has not been declared.' unless media_type
        Body.new media_type, value, self
      end
    end
  end
end
