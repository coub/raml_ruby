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

  subject { Raml::Root.new data }
  
  describe '#new' do
    it "should init root" do
      expect { subject }.to_not raise_error
    end

    context 'when the title property is missing' do
      let(:data) { { 'baseUri' => 'x' } }
      it { expect{ subject }.to raise_error Raml::RequiredPropertyMissing, /title/ }
    end
    context 'when the title property is not a string' do
      let(:data) { { 'title' => 1, 'baseUri' => 'x' } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /title/ }
    end
    
    context 'when the baseUri property is missing' do
      let(:data) { { 'title' => 'x' } }
      it { expect{ subject }.to raise_error Raml::RequiredPropertyMissing, /baseUri/ }
    end
    context 'when the baseUri property is not a string' do
      let(:data) { { 'title' => 'x', 'baseUri' => 1 } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /baseUri/ }
    end
  end
end
