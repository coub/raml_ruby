require_relative '../spec_helper'

describe Raml::Parameter::QueryParameter do
  let(:root_data) { {'title' => 'x', 'baseUri' => 'http://foo.com'} }
  let(:root) { Raml::Root.new root_data }
  let(:name) { 'page' }
  let(:data) {
    YAML.load(%q(
      type: integer
    ))
  }

  subject { Raml::Parameter::QueryParameter.new(name, data, root) }

  it "should instanciate Query parameter" do
    Raml::Parameter::QueryParameter.new(name, data, root)
  end
end
