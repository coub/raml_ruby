require_relative 'spec_helper'

describe Raml::Response do
  let (:name) { 200 }
  let (:response_data) {
    YAML.load(%q(
      displayName: Success
      description: Successful response
      body:
        text/xml:
          schema: some xml schema
          example: |
            <api-request>
              <input>s3://zencodertesting/test.mov</input>
            </api-request>
        application/json:
          schema: some json schema
          example: |
            {
              "input": "s3://zencodertesting/test.mov"
            }
      headers:
        Zencoder-Api-Key:
          displayName: ZEncoder API Key
        x-Zencoder-job-metadata-{*}:
          displayName: Job Metadata
    ))
  }
  let(:root) { Raml::Root.new 'title' => 'x', 'baseUri' => 'http://foo.com' }

  subject { Raml::Response.new name, response_data, root }

  describe '#new' do
    it "inits with name" do
      expect( subject.name ).to eq(name)
    end

    it "inits with headers" do
      expect( subject.headers.size ).to eq(2)
    end

    context 'when a body property is given' do
      context 'when the body property is well formed' do
        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Body instances' do
          expect( subject.bodies.values ).to all( be_a Raml::Body )
          expect( subject.bodies.size ).to eq(2)
          subject.bodies.keys.should contain_exactly('text/xml', 'application/json')
        end
      end
      context 'when the body property is not a map' do
        before { response_data['body'] = 1 }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /body/ }
      end
      context 'when the body property is a map with non-string keys' do
        before { response_data['body'] = { 1 => {}} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /body/ }
      end
      context 'when the body property is a map with non-map values' do
        before { response_data['body'] = { 'text/xml' => 1 } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /body/ }
      end
    end

    context 'when description property is not given' do
      before { response_data.delete 'description' }
      it { expect { subject }.to_not raise_error }
    end
    context 'when description property is given' do
      context 'when the description property is not a string' do
        before { response_data['description'] = 1 }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /description/ }
      end
      context 'when the description property is a string' do
        before { response_data['description'] = 'My Description' }
        it { expect { subject }.to_not raise_error }
        it 'should store the value' do
          subject.description.should eq response_data['description']
        end
      end
    end

    context 'when the headers parameter is given' do
      context 'when the headers property is well formed' do
        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Header instances' do
          expect( subject.headers.values ).to all( be_a Raml::Header )
          expect( subject.headers.keys ).to contain_exactly('Zencoder-Api-Key','x-Zencoder-job-metadata-{*}')
        end
      end
      context 'when the headers property is not a map' do
        before { response_data['headers'] = 1 }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /headers/ }
      end
      context 'when the headers property is not a map with non-string keys' do
        before { response_data['headers'] = { 1 => {}} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /headers/ }
      end
      context 'when the headers property is not a map with non-string keys' do
        before { response_data['headers'] = { '1' => 'x'} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /headers/ }
      end
    end
  end

  describe '#merge' do
    context 'when response and mixin have different status codes' do
      let(:response) { Raml::Response.new 200, {}, root }
      let(:mixin   ) { Raml::Response.new 403, {}, root }
      it { expect { response.merge mixin }.to raise_error Raml::MergeError }
    end

    context 'when response and mixin have different the same codes' do
      let(:response) { Raml::Response.new 200, response_data, root }
      let(:mixin   ) { Raml::Response.new 200, mixin_data   , root }
      context 'when the mixin has a property set' do
        context 'when the response does not have that property set' do
          let(:response_data) { {} }
          context 'displayName property' do
            let(:mixin_data) { {displayName: 'mixin displayName'} }
            it 'sets the property in the response' do
              response.merge(mixin).display_name.should eq mixin.display_name
            end
          end
          context 'description property' do
            let(:mixin_data) { {description: 'mixin description'} }
            it 'sets the property in the response' do
              response.merge(mixin).description.should eq mixin.description
            end
          end
          context 'headers properties' do
            let(:mixin_data) { {
              'headers' => {
                'header1' => {'description' => 'foo'},
                'header2' => {'description' => 'bar'}
              }
            } }
            it 'adds the headers to the response' do
               response.merge(mixin).headers.keys.should contain_exactly('header1', 'header2')
            end
          end
          context 'body property' do
            let(:mixin_data) { {
              'body' => {
                'text/mime1' => {'schema' => 'foo'},
                'text/mime2' => {'schema' => 'bar'}
              }
            } }
            it 'adds the body media types to the response' do
               response.merge(mixin).bodies.keys.should contain_exactly('text/mime1', 'text/mime2')
            end
          end
        end
        context 'when the response has that property set' do
          context 'displayName property' do
            let(:response_data) { {displayName: 'response displayName'} }
            let(:mixin_data ) { {displayName: 'mixin displayName' } }
            it 'overrites the response property' do
              response.merge(mixin).display_name.should eq 'mixin displayName'
            end
          end
          context 'description property' do
            let(:response_data) { {description: 'response description'} }
            let(:mixin_data ) { {description: 'mixin description' } }
            it 'overrites the response property' do
              response.merge(mixin).description.should eq 'mixin description'
            end
          end
          context 'headers properties' do
            let(:response_data) { {
              'headers' => {
                'header1' => {'description' => 'foo'},
                'header2' => {'description' => 'bar'}
              }
            } }
            context 'when the mixin headers are different from the response headers' do
              let(:mixin_data) { {
                'headers' => {
                  'header3' => {'description' => 'foo2'},
                  'header4' => {'description' => 'bar2'}
                }
              } }
              it 'adds the headers to the response' do
                 response.merge(mixin).headers.keys.should contain_exactly('header1', 'header2', 'header3', 'header4')
              end
            end
            context 'when the mixin headers overlap the the response headers' do
              let(:mixin_data) { {
                'headers' => {
                  'header2' => {'description' => 'bar3', 'displayName' => 'Header 3'},
                  'header3' => {'description' => 'foo2'},
                  'header4' => {'description' => 'bar2'}
                }
              } }
              it 'merges the matching headers and adds the non-matching headers to the response' do
                 response.merge(mixin).headers.keys.should contain_exactly('header1', 'header2', 'header3', 'header4')
                 response.headers['header2'].display_name.should eq mixin.headers['header2'].display_name
                 response.headers['header2'].description.should  eq mixin.headers['header2'].description
              end
            end
          end
          context 'body property' do
            let(:response_data) { {
              'body' => {
                'text/mime1' => {'schema' => 'foo'},
                'text/mime2' => {'schema' => 'bar'}
              }
            } }
            context 'when the mixin query parameters are different from the response headers' do
              let(:mixin_data) { {
                'body' => {
                  'text/mime3' => {'schema' => 'foo2'},
                  'text/mime4' => {'schema' => 'bar2'}
                }
              } }
              it 'adds the body media types to the response' do
                 response.merge(mixin).bodies.keys.should contain_exactly('text/mime1', 'text/mime2', 'text/mime3', 'text/mime4')
              end
            end
            context 'when the mixin query parameters overlap the the response query parameters' do
              let(:mixin_data) { {
                'body' => {
                  'text/mime2' => {'example' => 'Example 2'},
                  'text/mime3' => {'schema'  => 'foo2'},
                  'text/mime4' => {'schema'  => 'bar2'}
                }
              } }
              it 'merges the matching media types and adds the non-matching media types to the response' do
                 response.merge(mixin).bodies.keys.should contain_exactly('text/mime1', 'text/mime2', 'text/mime3', 'text/mime4')
                 response.bodies['text/mime2'].example.should eq mixin.bodies['text/mime2'].example
              end
            end
          end
        end
      end
    end
  end
end
