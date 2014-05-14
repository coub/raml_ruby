require_relative 'spec_helper'

describe Raml::Header do
  let(:name) { 'meta' }
  let (:data) {
    YAML.load(%q(
      displayName: Job Metadata
      description: Field names prefixed with x-Zencoder-job-metadata- contain user-specified metadata.
    ))
  }

  it "should instanciate Header" do
    Raml::Header.new(name, data)
  end
end
