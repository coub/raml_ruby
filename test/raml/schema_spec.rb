require_relative 'spec_helper'

describe Raml::Schema do
  let(:root_data) { {'title' => 'x', 'baseUri' => 'http://foo.com'} }
  let(:root) { Raml::Root.new root_data }
  subject { Raml::Schema.new 'MySchema', schema, root }
  
  describe '#new' do
    context 'with a valid schema' do
      context 'with a JSON Schema' do
        let(:schema) do 
          %q|
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
          |
        end

        it { expect { subject }.to_not raise_error }
        it { subject.should be_json_schema }
        it { subject.should_not be_xml_schema }
        it 'stores the schema in value' do
          subject.value.should == schema
        end
        it 'stores the name in name' do
          subject.name.should == 'MySchema'
        end
      end
      context 'with a XML Schema' do
        let(:schema) do 
          %q|
            <xs:schema attributeFormDefault="unqualified"
                       elementFormDefault="qualified"
                       xmlns:xs="http://www.w3.org/2001/XMLSchema">
              <xs:element name="api-request">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element type="xs:string" name="input"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
          </xs:schema>
          |
        end

        it { expect { subject }.to_not raise_error }
        it { subject.should_not be_json_schema }
        it { subject.should be_xml_schema }
      end
      context 'with a schema that is neither JSON Schema or XML Schema' do
        # A RELAX NG compact XML schema
        let(:schema) do 
          %q!
            # A library patron example
            default namespace = "http://some.other.url/ns"
            namespace foo = "http://home.of.foo/ns"
            datatypes xsd = "http://www.w3.org/2001/XMLSchema-datatypes"
            ## Annotation here
            element patron {
              element name { xsd:string { pattern = "\w{,10}" } }
              & element id-num { xsd:string }
              & element book {
                  ( attribute isbn { text }
                  | attribute title { text }
                  | attribute anonymous { empty })
                }*
            }
          !
        end

        it { expect { subject }.to_not raise_error }
        it { subject.should_not be_json_schema }
        it { subject.should_not be_xml_schema }
      end
    end
    context 'with an invalid schema' do
      context 'with a malformed JSON schema' do
        let(:schema) do 
          %q|
              "$schema": "http://json-schema.org/draft-04/schema#",
              "multipleOf" : "xxx"
            }
          |
        end

        it { expect { subject }.to raise_error Raml::InvalidSchema }
      end
      context 'with an invalid JSON schema' do
        let(:schema) do 
          %q|
            {
              "$schema": "http://json-schema.org/draft-04/schema#",
              "multipleOf" : "xxx"
            }
          |
        end

        it { expect { subject }.to raise_error Raml::InvalidSchema }
      end
    end
  end
end
