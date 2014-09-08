require_relative '../spec_helper'

describe Raml::Parameter::UriParameter do
  let(:root_data) { {'title' => 'x', 'baseUri' => 'http://foo.com'} }
  let(:root) { Raml::Root.new root_data }
  let(:name) { 'AccountSid' }
  let(:data) {
    YAML.load(%q(
      description: |
        An Account instance resource represents a single Twilio account.
      type: string
    ))
  }

  subject { Raml::Parameter::UriParameter.new(name, data, root) }

  describe '#new' do
    it "should instanciate Uri parameter" do
      Raml::Parameter::UriParameter.new(name, data, root)
    end
    
    context 'when no required attribute is given' do
      let(:data) { { } }
      it 'defaults to true' do
        subject.required.should == true
      end
    end
  end

  describe "#document" do
    let(:data) {
      YAML.load(%q(
        description: Specify the page that you want to retrieve
        type: integer
        required: true
        example: 1
      ))
    }

    it "prints out documentation" do
      subject.document
    end
  end
end
