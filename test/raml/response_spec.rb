require_relative 'spec_helper'

describe Raml::Response do
  let (:name) {
    "200"
  }

  let (:response_data) {
    YAML.load(%q(
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
          expect( subject.bodies ).to all( be_a Raml::Body )
          expect( subject.bodies.size ).to eq(2)
          subject.bodies.map(&:media_type).should contain_exactly('text/xml', 'application/json')
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
        it 'uses the description in the documentation' do
          subject.document.should include response_data['description']
        end
      end
    end
    
    context 'when the headers parameter is given' do
      context 'when the headers property is well formed' do
        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Header instances' do
          expect( subject.headers ).to all( be_a Raml::Header )
          expect( subject.headers.map(&:name) ).to contain_exactly('Zencoder-Api-Key','x-Zencoder-job-metadata-{*}')
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

  describe "#document" do
    it "prints out documentation" do
      subject.document
    end
  end
end
