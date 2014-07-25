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
          expect { Raml::Root.new({ 'title' => 'x', 'baseUri' => template, 'version' => 'v1' }) }.to_not raise_error
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
    
    [
       'application/json',
       'application/x-yaml',
       'application/foo+json',
       'application/foo+xml'
    ].each do |type|
      context 'when the mediaType property is a well formed media type' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'media_type' => type} }
        it { expect{ subject }.to_not raise_error }
      end
    end
    context 'when the mediaType property is not a string' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'media_type' => 1 } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /mediaType/ }
    end
    context 'when the mediaType property is a malformed media type' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'media_type' => 'foo' } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /mediaType/ }
    end
    
    context 'when the schemas property is an array of maps with string keys and values' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [{'foo'=>'bar'}] } }
      it { expect{ subject }.to_not raise_error }
    end
    context 'when the schemas property is an array with a single map' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [{'foo'=>'bar'}] } }
      it 'returns that map in the #schema method' do
        subject.schemas.should eq({'foo'=>'bar'})
      end
    end
    context 'when the schemas property is an array with multiple maps' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [{'foo'=>'bar'},{'boo'=>'bar'}] } }
      it 'returns the merged maps in the #schema method' do
        subject.schemas.should eq({'foo'=>'bar','boo'=>'bar'})
      end
    end
    context 'when the schemas property is not an array' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => 'x' } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /schemas/ }
    end
    context 'when the schemas property is an empty array' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [] } }
      it { expect{ subject }.to_not raise_error }
    end
    context 'when the schemas property is an array with some non-map elements' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [{'foo'=>'bar'}, 1] } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /schemas/ }
    end
    context 'when the schemas property is an array of maps with non-string keys' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [{1=>'bar'}] } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /schemas/ }
    end
    context 'when the schemas property is an array of maps with non-string values' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [{'foo'=>1}] } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /schemas/ }
    end
    context 'when the schemas property has duplicate schema names' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [{'foo'=>'bar'},{'foo'=>'boo'}] } }
      it { expect{ subject }.to raise_error Raml::InvalidProperty, /schemas/ }
    end
  
    context 'when the baseUriParameter property is well formed' do
      let(:data) {
        YAML.load(
          %q(
            title: Salesforce Chatter Communities REST API
            version: v28.0
            baseUri: https://{communityDomain}.force.com/{communityPath}
            baseUriParameters:
             communityDomain:
               displayName: Community Domain
               type: string
             communityPath:
               displayName: Community Path
               type: string
               pattern: ^[a-zA-Z0-9][-a-zA-Z0-9]*$
               minLength: 1
          )
        )
      }
      it { expect { subject }.to_not raise_error }
      it 'stores all as Raml::Parameter::BaseUriParameter instances' do
        expect( subject.base_uri_parameters ).to all( be_a Raml::Parameter::BaseUriParameter )
      end
      context 'when the baseUri template does not include a version parameter' do
        context 'and a version property is not provided' do
          before { data.delete 'version' }
          it { expect { subject }.to_not raise_error }
        end
      end
      context 'when the baseUri template includes a version parameter' do
        context 'and a version property is not provided' do
          before do
            data.delete 'version'
            data['baseUri'] = 'https://{communityDomain}.force.com/{version}/{communityPath}'
          end
          it { expect { subject }.to raise_error Raml::RequiredPropertyMissing, /version/ }
        end
      end
    end
    context 'when the baseUriParameter property is not a map' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'baseUriParameters' => 1 } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /baseUriParameters/ }
    end
    context 'when the baseUriParameter property is not a map with non-string keys' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'baseUriParameters' => { 1 => {}} } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /baseUriParameters/ }
    end
    context 'when the baseUriParameter property is not a map with non-string keys' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'baseUriParameters' => { '1' => 'x'} } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /baseUriParameters/ }
    end
    context 'when the baseUriParameter property has a key for the reserved "version" parameter' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'baseUriParameters' => { 'version' => {}} } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /baseUriParameters/ }
    end
  
    context 'when the documentation parameter is given and valid' do
      let(:data) {
        YAML.load(
          %q(
            #%RAML 0.8
            title: ZEncoder API
            baseUri: https://app.zencoder.com/api
            documentation:
             - title: Home
               content: |
                 Welcome to the _Zencoder API_ Documentation.
          )
        )
      }
      it { expect { subject }.to_not raise_error }
      it 'stores all as Raml::Documentation instances' do
        expect( subject.documents ).to all( be_a Raml::Documentation )
      end
    end
    context 'when the documentation property is not a array' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'documentation' => 1 } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /documentation/ }
    end
    context 'when the documentation property is an empty array' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'documentation' => [] } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /documentation/ }
    end
    context 'when an entry in the documentation property is missing the title' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'documentation' => [{'content' => 'x'}] } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /document/ }
    end
    context 'when an entry in the documentation property has an empty title' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'documentation' => [{'title' => '', 'content' => 'x'}] } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /document/ }
    end
    context 'when an entry in the documentation property is missing the content' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'documentation' => [{'title' => 'x'}] } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /document/ }
    end
    context 'when an entry in the documentation property has an empty content' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'documentation' => [{'title' => 'x', 'content' => ''}] } }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /document/ }
    end
    
    context 'when top-level resources are defined' do
      let(:data) {
        YAML.load(
          %q(
            #%RAML 0.8
            title: GitHub API
            version: v3
            baseUri: https://api.github.com
            /user:
              displayName: Authenticated User
            /users:
              displayName: Users
          )
        )
      }
      it { expect { subject }.to_not raise_error }
      it 'stores all as Raml::Resource instances' do
        expect( subject.resources ).to all( be_a Raml::Resource )
        expect( subject.resources.map(&:name) ).to contain_exactly('/user','/users')
      end
    end
  end
end
