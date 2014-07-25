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
  end
  describe "#document" do
    it "prints out documentation" do
      subject.document
    end
  end
end
