require_relative 'spec_helper'

describe Raml::Body do
  let (:media_type) {
    'text/xml'
  }

  let (:body_data) {
    YAML.load(%q(
      schema: !include job.xsd
    ))
  }

  subject { Raml::Body.new(media_type, body_data) }

  it "inits body with media_type" do
    expect( subject.media_type ).to eq(media_type)
  end

  it "inits body with schema" do
    expect( subject.schema ).to eq('job.xsd')
  end

  describe "#document" do
    let (:body_data) {
      YAML.load(%q(
        schema: !include job.xsd
      ))
    }

    it "prints out documentation" do
      subject.document
    end

  end
end
