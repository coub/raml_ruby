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
    context 'when the media type is "*/*"' do
      let(:media_type) { '*/*' }
      it 'inits the body with the media_type' do
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
                expect( subject.form_parameters.values ).to all( be_a Raml::Parameter::FormParameter )
                subject.form_parameters.keys.should contain_exactly('param')
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
        expect( subject.form_parameters.values ).to all( be_a Raml::Parameter::FormParameter )
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

  describe '#merge' do
    context 'when body and mixin have different media types' do
      let(:body ) { Raml::Body.new 'foo/bar', {}, root }
      let(:mixin) { Raml::Body.new 'foo/boo', {}, root }
      it { expect { body.merge mixin }.to raise_error Raml::MergeError }
    end
    context 'when body and mixin have the same media type' do
      let(:body ) { Raml::Body.new 'foo/bar', body_data , root }
      let(:mixin) { Raml::Body.new 'foo/bar', mixin_data, root }

      context 'when the body to merge in has a property set' do
        context 'when the body to merge into does not have the property set' do
          let(:body_data) { {} }
          context 'example property' do
            let(:mixin_data) { {'example' => 'body example'} }
            it 'merges in the property' do
              body.merge(mixin).example.should eq mixin.example
            end
          end
          context 'schema property' do
            let(:mixin_data) { {'schema' => 'mixin schema'} }
            it 'merges in the property' do
              body.merge(mixin).schema.should be_a Raml::Schema
              body.schema.should eq mixin.schema
            end
          end
          context 'formParameters properties' do
            let(:mixin_data) { {
              'formParameters' => {
                'param1' => {'description' => 'foo'},
                'param2' => {'description' => 'bar'}
              }
            } }
            it 'adds the form parameters to the body' do
               body.merge(mixin).form_parameters.keys.should contain_exactly('param1', 'param2')
            end
          end
        end
        context 'when the body to merge into has the property set' do
          context 'example property' do
            let(:body_data ) { {'example' => 'body example'}  }
            let(:mixin_data) { {'example' => 'mixin example'} }
            it 'overrides the property' do
              body.merge(mixin).example.should eq 'mixin example'
            end
          end
          context 'schema property' do
            let(:body_data ) { {'schema' => 'body schema' } }
            let(:mixin_data) { {'schema' => 'mixin schema'} }
            it 'overrides the property' do
              body.merge(mixin).schema.value.should eq 'mixin schema'
            end
          end
          context 'formParameters properties' do
            let(:body_data) { {
              'formParameters' => {
                'param1' => {'description' => 'foo'},
                'param2' => {'description' => 'bar'}
              }
            } }
            context 'when the merged in body form parameters are different from the form parametes of the body merged into' do
              let(:mixin_data) { {
                'formParameters' => {
                  'param3' => {'description' => 'foo2'},
                  'param4' => {'description' => 'bar2'}
                }
              } }
              it 'adds the form parameters to the body' do
                 body.merge(mixin).form_parameters.keys.should contain_exactly('param1', 'param2', 'param3', 'param4')
              end
            end
            context 'when the merged in body form parameters overlap with the form parametes of the body merged into' do
              let(:mixin_data) { {
                'formParameters' => {
                  'param2' => {'description' => 'bar3', 'displayName' => 'Param 3'},
                  'param3' => {'description' => 'foo2'},
                  'param4' => {'description' => 'bar2'}
                }
              } }
              it 'merges the matching orm parameters and adds the non-matching orm parameters to the body' do
                 body.merge(mixin).form_parameters.keys.should contain_exactly('param1', 'param2', 'param3', 'param4')
                 body.form_parameters['param2'].display_name.should eq mixin.form_parameters['param2'].display_name
                 body.form_parameters['param2'].description.should  eq mixin.form_parameters['param2'].description
              end
            end
          end
        end
      end
    end
  end
end
