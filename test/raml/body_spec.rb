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
  
  let(:form_body_data) {
    YAML.load(%q(
      formParameters:
        param:
          type: string
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

  describe '#form_parameters' do
    context 'when body is not a web form' do
      it 'returns no form parameters' do
        subject.form_parameters { should be_empty }
      end
    end
    context 'when body is a web form' do
      let(:body_data) { form_body_data }
      it 'returns form parameters' do
        subject.form_parameters { should_not be_empty }
        subject.form_parameters.all? { |fp| fp.is_a? Raml::Parameter::FormParameter }.should be true
      end
    end
  end
  
  end
end
