# encoding: UTF-8
require_relative 'spec_helper'

describe Raml::Resource do
  let(:name) { '/{id}' }
  let(:data) {
    YAML.load(%q(
      uriParameters:
        id:
          type: integer
          required: true
          example: 277102
      /processing_status:
        get:
          displayName: Processing status
          description: Получить статус загрузки
          responses:
            200:
              body:
                application/json:
                  example: |
                    {
                      "percent": 0,
                      "type": "download",
                      "status":"initial"
                    }
    ))
  }

  subject { Raml::Resource.new(name, data) }

  describe '#new' do
    it "should instanciate Resource" do
      subject
    end
    
    context 'when displayName is not given' do
      let(:data) { {} }
      it { expect { subject }.to_not raise_error }
      it 'uses the resource relative URI in the documentation' do
        subject.document.should include name
      end
    end
    context 'when displayName is given' do
      let(:data) { { 'displayName' => 'My Name'} }
      it { expect { subject }.to_not raise_error }
      it 'should store the value' do
        subject.display_name.should eq data['displayName']
      end
      it 'uses the displayName in the documentation' do
        subject.document.should include data['displayName']
      end
    end
    
    context 'when description is not given' do
      let(:data) { {} }
      it { expect { subject }.to_not raise_error }
    end
    context 'when description is given' do
      let(:data) { { 'description' => 'My Description'} }
      it { expect { subject }.to_not raise_error }
      it 'should store the value' do
        subject.description.should eq data['description']
      end
      it 'uses the description in the documentation' do
        subject.document.should include data['description']
      end
    end
    
    context 'when the uriParameters parameter is given with valid parameters' do
      context 'when the uriParameters property is well formed' do
        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Parameter::UriParameter instances' do
          expect( subject.uri_parameters ).to all( be_a Raml::Parameter::UriParameter )
        end
      end
      context 'when the uriParameters property is not a map' do
        let(:data) { { 'uriParameters' => 1 } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /uriParameters/ }
      end
      context 'when the uriParameters property is not a map with non-string keys' do
        let(:data) { { 'uriParameters' => { 1 => {}} } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /uriParameters/ }
      end
      context 'when the uriParameters property is not a map with non-string keys' do
        let(:data) { { 'uriParameters' => { '1' => 'x'} } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /uriParameters/ }
      end
    end
  end
  
  describe "#document" do
    it "prints out documentation" do
      subject.document
    end
  end
end
