module Raml
  module Headers
    # @!attribute [r] headers
    #   @return [Hash<String, Raml::Header>] the headers, keyed by the header name.

    # XXX - need this line here to trigger Yard to generate docs for the above attribute.

    private

    def self.included(base)
      base.instance_eval do
        non_scalar_property :headers
        children_by :headers, :name, Header
      end
    end

    def parse_headers(value)
      validate_hash 'headers', value, String, Hash
      value.map { |h_name, h_data| Header.new h_name, h_data, self }
    end
  end
end
