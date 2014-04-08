require_relative 'spec_helper'

describe Raml::Parser do
  let (:data) {
    %q(
      #%RAML 0.8
      baseUri: https://api.example.com
      title: Filesystem API
      version: 0.1
      schemas:
        - !include path-to-canonical-schemas/canonicalSchemas.raml
        - File:       !include path-to-schemas/filesystem/file.xsd
      /files:
        get:
          responses:
            200:
              body:
                application/xml:
                  schema: Files
    )
  }

  it "should parse the data" do
    parser = Raml::Parser.new(data)
    parser.parse
  end
end
