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

  subject { Raml::Response.new(name, response_data) }

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
  end

  describe "#document" do
    it "prints out documentation" do
      subject.document
    end
  end
end
