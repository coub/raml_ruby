require_relative 'spec_helper'

describe Raml::Response do
  let (:name) {
    "200"
  }

  let (:response_data) {
    YAML.load(%q(
      description: Successful response
      body:
        application/json:
          schema: !include instagram-v1-meta-error.schema.json
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
    headers = subject.children.select{|child| child.is_a?(Raml::Header)}
    expect( headers.size ).to eq(2)
  end

  it "inits with body" do
    headers = subject.children.select{|child| child.is_a?(Raml::Body)}
    expect( headers.size ).to eq(1)
  end
end
