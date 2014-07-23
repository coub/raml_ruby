require_relative 'spec_helper'

describe Raml::Root do
  let (:data) {
    YAML.load(
      %q(
        #%RAML 0.8
        title: ZEncoder API
        baseUri: https://app.zencoder.com/api
        documentation:
         - title: Home
           content: Doc content
      )
    )
  }

  describe '#new' do
    it "should init root" do
      expect { Raml::Root.new(data) }.to_not raise_error
    end

    context 'when the title property is missing' do
      it  { expect{ Raml::Root.new({'baseUri' => 'x'}) }.to raise_error Raml::RootTitleMissing }
    end
    
    context 'when the baseUri property is missing' do
      it { expect{ Raml::Root.new({'title' => 'x'}) }.to raise_error Raml::RootBaseUriMissing }
    end
  end
end
