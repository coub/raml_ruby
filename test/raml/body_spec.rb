require_relative 'spec_helper'

describe Raml::Body do
  let (:name) {
    'text/xml'
  }

  let (:body_data) {
    YAML.load(%q(
      schema: !include job.xsd
    ))
  }

  subject { Raml::Body.new(name, body_data) }

  it "inits body with name" do
    expect( subject.name ).to eq(name)
  end

  it "inits body with schema" do
    expect( subject.schema ).to eq('job.xsd')
  end
end
