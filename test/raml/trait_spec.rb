require_relative 'spec_helper'

describe Raml::Trait do
	let(:name) { 'secured' }
  let(:data) {
    YAML.load(%q(
      usage: Apply this to any method that needs to be secured
      description: Some requests require authentication.
      queryParameters:
        access_token:
          description: Access Token
          type: string
          example: ACCESS_TOKEN
          required: true
    ))
  }
  let(:root) { Raml::Root.new 'title' => 'x', 'baseUri' => 'http://foo.com' }

  subject { Raml::Trait.new name, data, root }

  describe '#new' do
  	context 'when the trait name is not an HTTP method name' do
      it { expect { subject }.to_not raise_error }
    end
    context 'when the usage property is given' do
	    it 'stores the usage property' do
	    	subject.instantiate({}).usage.should eq data['usage']
	    end
	  end
  end
end