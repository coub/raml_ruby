module Raml
  module Headers
    def self.included(base)
      base.instance_eval do
		    non_scalar_property :headers
        children_by :headers, :name, Header
      end
    end

    private

    def parse_headers(value)
      validate_hash 'headers', value, String, Hash
      value.map { |h_name, h_data| Header.new h_name, h_data, self }
    end
  end
end
