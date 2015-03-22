require_relative 'spec_helper'

describe Raml::Header do
  let(:root_data) { {'title' => 'x', 'baseUri' => 'http://foo.com'} }
  let(:root) { Raml::Root.new root_data }
  let(:name) { 'meta' }
  let (:data) {
    YAML.load(%q(
      displayName: Job Metadata
      description: Field names prefixed with x-Zencoder-job-metadata- contain user-specified metadata.
    ))
  }

  it "should instanciate Header" do
    Raml::Header.new(name, data, root)
  end
end
