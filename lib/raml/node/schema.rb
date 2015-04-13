require 'json-schema'

module Raml
  class Schema < ValueNode
    # @return [Boolean] true if the schema appears to be an JSON Schema, false otherwise.
    def json_schema?
      /"\$schema":\s*"http:\/\/json-schema.org\/[^"]*"/ === @value
    end

    # @return [Boolean] true if the schema appears to be an XML Schema, false otherwise.
    def xml_schema?
      /<xs:schema [^>]*xmlns:xs="http:\/\/www\.w3\.org\/2001\/XMLSchema"[^>]*>/ === @value
    end

    private

    def validate_value
      validate_json if json_schema?
    end

    def validate_json
      parsed_schema = JSON.parse @value
      version = parsed_schema['$schema']
      # json-schema gem doesn't handle this lastest version string
      version = nil if version == 'http://json-schema.org/schema#'
      # fix up schema versions URLs that don't end in "#""
      version = "#{version}#" if version =~ /\Ahttps?:\/\/json-schema\.org\/draft-\d\d\/schema\z/

      meta_schema = JSON::Validator.validator_for_name(version).metaschema
      JSON::Validator.validate! meta_schema, parsed_schema
    rescue JSON::ParserError, JSON::Schema::SchemaError, JSON::Schema::ValidationError => e
      raise InvalidSchema, "Could not parse JSON Schema: #{e}"
    end
  end
end
