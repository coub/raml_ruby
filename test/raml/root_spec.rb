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
    context 'when the baseUri property is a valid URL' do
      it 'should not raise an error' do
        [
          'https://api.github.com',
          'https://app.zencoder.com/api'
        ].each do |template|
          expect { Raml::Root.new({ 'title' => 'x', 'baseUri' => template }) }.to_not raise_error
        end
      end
    end
    context 'when the baseUri property is an invalid URL template' do
      let(:data) { { 'title' => 'x', 'baseUri' => '://app.zencoder.com/api' } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /baseUri/ }
    end
    context 'when the baseUri property is a URL template' do
      it 'should not raise an error' do
        [
          'https://{destinationBucket}.s3.amazonaws.com',
          'https://na1.salesforce.com/services/data/{version}/chatter',
          'https://api.stormpath.com/{version}',
          'https://{companyName}.freshbooks.com/api/{version}/xml-in',
          'https://{communityDomain}.force.com/{communityPath}',
          'https://app.zencoder.com/api/{version}',
          'https://{apiDomain}.dropbox.com/{version}'
        ].each do |template|
          expect { Raml::Root.new({ 'title' => 'x', 'baseUri' => template }) }.to_not raise_error
        end
      end
    end
    context 'when the baseUri property is an invalid URL template' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'https://api.stormpath.com/}version}' } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /baseUri/ }
    end
    
    context 'when the protocols property is missing' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com' } }
      it { expect{ subject }.to_not raise_error }
    end
    context 'when the protocol property is not an array' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'protocols' => 'HTTP' } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /protocols/ }
    end
    context 'when the protocol property is an array but not all elements are strings' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'protocols' => ['HTTP', 1] } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /protocols/ }
    end
    context 'when the protocol property is an array of strings with invalid values' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'protocols' => ['HTTP', 'foo'] } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /protocols/ }
    end
    [
      [ 'HTTP'  ],
      [ 'HTTPS' ],
      [ 'HTTP', 'HTTPS' ]
    ].each do |protocols|
      context "when the protocol property is #{protocols}" do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'protocols' => protocols } }
        it { expect{ subject }.to_not raise_error }
        it 'stores the values' do
          subject.protocols.should eq protocols
        end
      end
    end
    context 'when the protocol property is an array of valid values in lowercase' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'protocols' => ['http', 'https'] } }
      it 'uppercases them' do
        subject.protocols.should eq [ 'HTTP', 'HTTPS' ]
      end
    end
  end
end
