require_relative 'spec_helper'

describe Raml do
  describe '#parse_file' do
    let(:rest_of_doc) { "title: Some API\nbaseUri: https://app.zencoder.com/api" }
    before do 
      stub(File).new('file.raml').stub! do |stub|
        stub.readline { comment     } 
        stub.read     { rest_of_doc }
      end
    end
    context 'when given a valid RAML 0.8 file with a valid version comment' do
      let(:comment    ) { '#%RAML 0.8'      }
      it do
        expect { Raml.parse_file 'file.raml' }.to_not raise_error
      end
    end
    context 'when given a valid RAML 0.8 file with an invalid version comment' do
      let(:comment    ) { '#%RAML 0.7'      }
      it do
        expect { Raml.parse_file 'file.raml' }.to raise_error Raml::UnsupportedRamlVersion
      end
    end
    context 'when given a valid RAML 0.8 file with no version comment' do
      let(:comment    ) { 'title: Some API' }
      let(:rest_of_doc) { 'version: v2'     }
      it do
        expect { Raml.parse_file 'file.raml' }.to raise_error Raml::UnsupportedRamlVersion
      end
    end
  end
end