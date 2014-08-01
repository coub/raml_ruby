require_relative 'spec_helper'

describe Raml::Body do
  let (:media_type) { 'text/xml' }
  let (:body_data ) {
    YAML.load(%q(
      schema: |
        {
          "$schema": "http://json-schema.org/draft-03/schema#",
          "properties": {
              "input": {
                  "required": false,
                  "type": "string"
              }
          },
          "required": false,
          "type": "object"
        }
    ))
  }  
  let(:form_body_data) {
    YAML.load(%q(
      formParameters:
        param:
          type: string
    ))
  }
  let(:root) { Raml::Root.new 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [{'Job' => 'xxx'}] }

  subject { Raml::Body.new media_type, body_data, root }
  
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
      context 'when the schema property is valid schema' do
        it "inits body with schema" do
          expect( subject.schema ).to be_an Raml::Schema
        end
      end
      context 'when the schema property is valid schema reference' do
        let (:body_data ) { { 'schema' => 'Job' } }
        it "inits body with schema" do
          expect( subject.schema ).to be_an Raml::SchemaReference
        end
      end
      context 'when the schema property is not a string' do
        let (:body_data ) { { 'schema' => 1 } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /schema/ }
      end
      context 'when the schema property is an empty string' do
        let (:body_data ) { { 'schema' => '' } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /schema/ }
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
            context 'when a formParameters property is valid' do
              it { expect { subject }.to_not raise_error }
              it 'stores all as Raml::Parameter::FormParameter instances' do
                expect( subject.form_parameters ).to all( be_a Raml::Parameter::FormParameter )
                subject.form_parameters.map(&:name).should contain_exactly('param')
              end
            end
            context 'when the formParameters property is not a map' do
              before { body_data['formParameters'] = 1 }
              it { expect { subject }.to raise_error Raml::InvalidProperty, /formParameters/ }
            end
            context 'when the formParameters property is not a map with non-string keys' do
              before { body_data['formParameters'] = { 1 => {}} }
              it { expect { subject }.to raise_error Raml::InvalidProperty, /formParameters/ }
            end
            context 'when the formParameters property is not a map with non-string keys' do
              before { body_data['formParameters'] = { '1' => 'x'} }
              it { expect { subject }.to raise_error Raml::InvalidProperty, /formParameters/ }
            end
          end
          
          context 'when a schema property is not provided' do
            it { expect { subject }.to_not raise_error }
          end
          context 'when a schema property is provided' do
            let(:body_data) {
              YAML.load %q(
                schema: |
                  {
                    "$schema": "http://json-schema.org/draft-03/schema#",
                    "properties": {
                        "input": {
                            "required": false,
                            "type": "string"
                        }
                    },
                    "required": false,
                    "type": "object"
                  }
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
