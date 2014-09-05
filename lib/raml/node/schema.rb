require 'json-schema'

module Raml
  class Schema
		attr_accessor :name, :value

  	def initialize(name, schema)
  		@name  = name
  		@value = schema

  		validate_json if json_schema?
  	end

  	def json_schema?
  		/"\$schema":\s*"http:\/\/json-schema.org\/[^"]*"/ === @value
  	end

  	def xml_schema?
  		/<xs:schema [^>]*xmlns:xs="http:\/\/www\.w3\.org\/2001\/XMLSchema"[^>]*>/ === @value
  	end

  	private

  	def validate_json
			parsed_schema = JSON.parse @value
			version = parsed_schema['$schema']
			# json-schema gem doesn't handly this lastest version string
			version = nil if version == 'http://json-schema.org/schema#'

			meta_schema = JSON::Validator.metaschema_for JSON::Validator.version_string_for version
      JSON::Validator.validate! meta_schema, parsed_schema
    rescue JSON::ParserError, JSON::Schema::SchemaError, JSON::Schema::ValidationError => e
    	raise InvalidSchema, "Could not parse JSON Schema: #{e}"    	
		end
  end
end