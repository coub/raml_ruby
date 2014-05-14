require_relative 'spec_helper'

describe Raml::Response do
  let (:name) {
    "200"
  }

  let (:response_data) {
    YAML.load(%q(
      description: Successful response
      body:
        text/xml:
          schema: !include job.xsd
          example: |
            <api-request>
              <input>s3://zencodertesting/test.mov</input>
            </api-request>
        application/json:
          schema: !include job.schema.json
          example: |
            {
              "input": "s3://zencodertesting/test.mov"
            }
      headers:
        Zencoder-Api-Key:
          displayName: ZEncoder API Key
        x-Zencoder-job-metadata-{*}:
          displayName: Job Metadata
    ))
  }

  subject { Raml::Response.new(name, response_data) }

  it "inits with name" do
    expect( subject.name ).to eq(name)
  end

  it "inits with headers" do
    expect( subject.headers.size ).to eq(2)
  end

  it "inits with body" do
    expect( subject.bodies.size ).to eq(2)
  end

  describe "#document" do
    it "prints out documentation" do
      subject.document

      # puts "\n"
      # puts subject.document
      # puts "\n"
    end
  end
end
