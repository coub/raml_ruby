require_relative '../spec_helper'

describe Raml::Parameter::QueryParameter do
  let(:name) { 'page' }
  let(:data) {
    YAML.load(%q(
      page:
        type: integer
      per_page:
        type: integer
    ))
  }

  it "should instanciate Query parameter" do
    Raml::Parameter::QueryParameter.new(name, data)
  end
end
