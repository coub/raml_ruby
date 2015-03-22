require_relative 'spec_helper'

describe Raml::Parser do
  let (:data) {
    %q(
      #%RAML 0.8
      baseUri: https://api.example.com
      title: Filesystem API
      version: 0.1
      /files:
        get:
          responses:
            200:
              body:
                application/xml:
                  schema: Files
    )
  }

  describe '.parse' do
    it "should parse the data" do
      root = Raml::Parser.parse(data)
      root.should be_a Raml::Root
      root.title.should eq 'Filesystem API'
    end
    
    context 'when the RAML file has !include directives' do
      it 'inserts the data into the right location and parses RAML included files' do
        file = File.new 'fixtures/include_1.raml'
        root = Raml::Parser.parse file.read, 'fixtures'
        root.schemas.should be_a Hash
        root.schemas.size.should be 4
        root.schemas.keys.should contain_exactly('FileUpdate', 'Files', 'Test', 'File')
        root.schemas['FileUpdate'].value.should eq 'file_update_schema'
        root.schemas['Files'     ].value.should eq 'files_schema'
        root.schemas['Test'      ].value.should eq 'test_schema'
        root.schemas['File'      ].value.should eq 'file_schema'
      end
      
      context 'when the included file is not redable' do
        it do
          expect { Raml::Parser.parse('- !include does_not_exit') }.to raise_error Raml::CantIncludeFile
        end
      end
      
      context 'when the !include directive is not given a file path' do
        it do
          expect { Raml::Parser.parse('- !include') }.to raise_error Raml::CantIncludeFile
        end
      end
    end
  end
end
