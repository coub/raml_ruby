require_relative 'spec_helper'

describe Raml::Body do
  let (:media_type) { 'text/xml' }
  let (:body_data ) {
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
  
  describe '#initialize' do
    context 'when the media type is valid' do
      it "inits body with media_type" do
        expect( subject.media_type ).to eq media_type
      end
    end
    context 'when the media type is invalid' do
      let(:media_type) { 'foo' }
      it { expect { subject }.to raise_error Raml::InvalidMediaType }
    end

    context 'when the body is not a web form' do
      it "inits body with schema" do
        expect( subject.schema ).to eq('job.xsd')
      end
    end
    context 'when body is a web form' do
      let(:body_data) { form_body_data }
      [ 'application/x-www-form-urlencoded', 'multipart/form-data' ].each do |mtype|
        context "when media type is #{mtype}" do
          let(:media_type) { mtype }
          context 'when a formParameters property is not provided' do
            before { body_data.delete 'formParameters' }
            it { expect { subject }.to raise_error Raml::RequiredPropertyMissing, /formParameters/ }
          end
          context 'when a formParameters property is provided' do
            it { expect { subject }.to_not raise_error }
          end
          
          context 'when a schema property is not provided' do
            it { expect { subject }.to_not raise_error }
          end
          context 'when a schema property is provided' do
            let(:body_data) {
              YAML.load %q(
                schema: !include job.xsd
                formParameters:
                  param:
                    type: string
              )
            }
            it { expect { subject }.to raise_error Raml::InvalidProperty, /schema/ }
          end
        end
      end      
    end
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
  
  describe '#web_form?' do
    context 'when body isnt a web form' do
      it { should_not be_web_form }
    end
    context 'when body is a web form' do
      let(:body_data) { form_body_data }
      [ 'application/x-www-form-urlencoded', 'multipart/form-data' ].each do |mtype|
        context "when media type is #{mtype}" do
          let(:media_type) { mtype }
          it { should be_web_form }
        end
      end
    end
  end
end
