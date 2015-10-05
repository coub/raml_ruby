require_relative 'spec_helper'

describe Raml::Root do
  let(:data) {
    YAML.load(
      %q(
        #%RAML 0.8
        title: ZEncoder API
        baseUri: https://app.zencoder.com/api
        version: v2.0
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
        subject.schemas.should be_a Hash
        subject.schemas.keys.should contain_exactly('foo')
        subject.schemas['foo'].should be_a Raml::Schema
        subject.schemas['foo'].value.should == 'bar'
      end
    end
    context 'when the schemas property is an array with multiple maps' do
      let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'schemas' => [{'foo'=>'bar', 'roo'=>'rar'},{'boo'=>'bar'}] } }
      it 'returns the merged maps in the #schema method' do
        subject.schemas.should be_a Hash
        subject.schemas.keys.should contain_exactly('foo', 'roo', 'boo')
        subject.schemas.values.should all(be_a Raml::Schema)
        subject.schemas.values.map(&:value).should contain_exactly('bar', 'rar', 'bar')
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
        expect( subject.base_uri_parameters.values ).to all( be_a Raml::Parameter::BaseUriParameter )
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
        expect( subject.resources.values ).to all( be_a Raml::Resource )
        expect( subject.resources.keys   ).to contain_exactly('/user','/users')
      end
    end

    context 'when the resourceTypes property is defined' do
      context 'when the resourceTypes property is an array of maps with string keys and and map values' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => [{'foo'=>{},'boo'=>{}}] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the resourceTypes property is an array with a single map' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => [{'foo'=>{}}] } }
        it 'returns the ResourceType in the #resource_types method' do
          subject.resource_types.should be_a Hash
          subject.resource_types.keys.should contain_exactly('foo')
          subject.resource_types['foo'].should be_a Raml::ResourceType
          subject.resource_types['foo'].name.should == 'foo'
        end
        context 'when the resourceTypes property is an array with a single map with multiple types' do
          let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => [{'foo'=>{},'boo'=>{}}] } }
          it 'returns the ResourceTypes in the #resource_types method' do
            subject.resource_types.should be_a Hash
            subject.resource_types.keys.should contain_exactly('foo', 'boo')
            subject.resource_types.values.should all(be_a Raml::ResourceType)
            subject.resource_types.values.map(&:name).should contain_exactly('foo', 'boo')
          end
        end
      end
      context 'when the resourceTypes property is an array with multiple maps' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => [{'foo'=>{}},{'boo'=>{}}] } }
        it 'returns the merged maps in the #resource_types method' do
          subject.resource_types.should be_a Hash
          subject.resource_types.keys.should contain_exactly('foo', 'boo')
          subject.resource_types.values.should all(be_a Raml::ResourceType)
          subject.resource_types.values.map(&:name).should contain_exactly('foo', 'boo')
        end
      end
      context 'when the resourceTypes property is not an array' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => 'x' } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /resourceTypes/ }
      end
      context 'when the resourceTypes property is an empty array' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => [] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the resourceTypes property is an array with some non-map elements' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => [{'foo'=>{}}, 1] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /resourceTypes/ }
      end
      context 'when the resourceTypes property is an array of maps with non-string keys' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => [{1=>{}}] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /resourceTypes/ }
      end
      context 'when the resourceTypes property is an array of maps with non-map values' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => [{'foo'=>1}] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /resourceTypes/ }
      end
      context 'when the resourceTypes property has duplicate type names' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'resourceTypes' => [{'foo'=>{}},{'foo'=>{}}] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /resourceTypes/ }
      end
    end

    context 'when the traits property is defined' do
      context 'when the traits property is an array of maps with string keys and and map values' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => [{'foo'=>{},'boo'=>{}}] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the traits property is an array with a single map' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => [{'foo'=>{}}] } }
        it 'returns the Trait in the #traits method' do
          subject.traits.should be_a Hash
          subject.traits.keys.should contain_exactly('foo')
          subject.traits['foo'].should be_a Raml::Trait
          subject.traits['foo'].name.should == 'foo'
        end
        context 'when the traits property is an array with a single map with multiple traits' do
          let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => [{'foo'=>{},'boo'=>{}}] } }
          it 'returns the Traits in the #traits method' do
            subject.traits.should be_a Hash
            subject.traits.keys.should contain_exactly('foo', 'boo')
            subject.traits.values.should all(be_a Raml::Trait)
            subject.traits.values.map(&:name).should contain_exactly('foo', 'boo')
          end
        end
      end
      context 'when the traits property is an array with multiple maps' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => [{'foo'=>{}},{'boo'=>{}}] } }
        it 'returns the merged maps in the #traits method' do
          subject.traits.should be_a Hash
          subject.traits.keys.should contain_exactly('foo', 'boo')
          subject.traits.values.should all(be_a Raml::Trait)
          subject.traits.values.map(&:name).should contain_exactly('foo', 'boo')
        end
      end
      context 'when the traits property is not an array' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => 'x' } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /traits/ }
      end
      context 'when the traits property is an empty array' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => [] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the traits property is an array with some non-map elements' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => [{'foo'=>{}}, 1] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /traits/ }
      end
      context 'when the traits property is an array of maps with non-string keys' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => [{1=>{}}] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /traits/ }
      end
      context 'when the traits property is an array of maps with non-map values' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => [{'foo'=>1}] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /traits/ }
      end
      context 'when the traits property has duplicate trait names' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'traits' => [{'foo'=>{}},{'foo'=>{}}] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /traits/ }
      end
    end

    context 'when the securedBy property is defined' do
      context 'when the securitySchemes property is an array of strings' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securedBy' => ['oauth_2_0', 'oauth_1_0'], 'securitySchemes' => ['oauth_2_0' => {'type' => 'OAuth 2.0'}, 'oauth_1_0' => {'type' => 'OAuth 1.0'}] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the securitySchemes property is an array of strings and "null"' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securedBy' => ['oauth_2_0', 'null'], 'securitySchemes' => ['oauth_2_0' => {'type' => 'OAuth 2.0'}] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the securitySchemes property is an array of hash with single key' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securedBy' => ['oauth_2_0' => {'scopes' => 'ADMINISTRATOR'}], 'securitySchemes' => ['oauth_2_0' => {'type' => 'OAuth 2.0'}] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the securitySchemes property references a missing security scheme' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securedBy' => ['bar'], 'securitySchemes' => ['oauth_2_0' => {'type' => 'OAuth 2.0'}] } }
        it { expect{ subject }.to raise_error Raml::UnknownSecuritySchemeReference, /bar/}
      end
    end

    context 'when the securitySchemes property is defined' do
      context 'when the securitySchemes property is an array of maps with string keys and and map values' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => [{'foo'=>{},'boo'=>{}}] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the securitySchemes property is an array with a single map' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => [{'foo'=>{}}] } }
        it 'returns the SecurityScheme in the #security_schemes method' do
          subject.security_schemes.should be_a Hash
          subject.security_schemes.keys.should contain_exactly('foo')
          subject.security_schemes['foo'].should be_a Raml::SecurityScheme
          subject.security_schemes['foo'].name.should == 'foo'
        end
        context 'when the securitySchemes property is an array with a single map with multiple types' do
          let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => [{'foo'=>{},'boo'=>{}}] } }
          it 'returns the SecuritySchemes in the #security_schemes method' do
            subject.security_schemes.should be_a Hash
            subject.security_schemes.keys.should contain_exactly('foo', 'boo')
            subject.security_schemes.values.should all(be_a Raml::SecurityScheme)
            subject.security_schemes.values.map(&:name).should contain_exactly('foo', 'boo')
          end
        end
      end
      context 'when the securitySchemes property is an array with multiple maps' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => [{'foo'=>{}},{'boo'=>{}}] } }
        it 'returns the merged maps in the #security_schemes method' do
          subject.security_schemes.should be_a Hash
          subject.security_schemes.keys.should contain_exactly('foo', 'boo')
          subject.security_schemes.values.should all(be_a Raml::SecurityScheme)
          subject.security_schemes.values.map(&:name).should contain_exactly('foo', 'boo')
        end
      end
      context 'when the securitySchemes property is not an array' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => 'x' } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /securitySchemes/ }
      end
      context 'when the securitySchemes property is an empty array' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => [] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the securitySchemes property is an array with some non-map elements' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => [{'foo'=>{}}, 1] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /securitySchemes/ }
      end
      context 'when the securitySchemes property is an array of maps with non-string keys' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => [{1=>{}}] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /securitySchemes/ }
      end
      context 'when the securitySchemes property is an array of maps with non-map values' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => [{'foo'=>1}] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /securitySchemes/ }
      end
      context 'when the securitySchemes property has duplicate type names' do
        let(:data) { { 'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => [{'foo'=>{}},{'foo'=>{}}] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /securitySchemes/ }
      end
    end
  end

  describe '#expand' do
    context 'when the syntax trees contains SchemaReferences' do
      let(:data) {
        YAML.load(
          %q(
            #%RAML 0.8
            title: ZEncoder API
            baseUri: https://app.zencoder.com/api
            schemas:
              - XMLJob: |
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
                JSONJob: |
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
            /jobs:
              displayName: Jobs
              post:
                description: Create a Job
                body:
                  text/xml:
                    schema: XMLJob
                  application/json:
                    schema: JSONJob
                responses:
                  200:
                    body:
                      text/xml:
                        schema: XMLJob
                      application/json:
                        schema: JSONJob
          )
        )
      }
      it 'replaces them with Schemas' do
        subject.resources['/jobs'].methods['post'].bodies['text/xml'        ].schema.should be_a Raml::SchemaReference
        subject.resources['/jobs'].methods['post'].bodies['application/json'].schema.should be_a Raml::SchemaReference
        subject.resources['/jobs'].methods['post'].responses[200].bodies['text/xml'        ].schema.should be_a Raml::SchemaReference
        subject.resources['/jobs'].methods['post'].responses[200].bodies['application/json'].schema.should be_a Raml::SchemaReference
        subject.expand
        subject.resources['/jobs'].methods['post'].bodies['text/xml'        ].schema.should be_a Raml::Schema
        subject.resources['/jobs'].methods['post'].bodies['application/json'].schema.should be_a Raml::Schema
        subject.resources['/jobs'].methods['post'].responses[200].bodies['text/xml'        ].schema.should be_a Raml::Schema
        subject.resources['/jobs'].methods['post'].responses[200].bodies['application/json'].schema.should be_a Raml::Schema
      end
    end

    context 'when the syntax tree contains Resources' do
      let(:data) {
        YAML.load(
          %q(
            #%RAML 0.8
            title: Example API
            version: v1
            baseUri: https://app.zencoder.com/api
            resourceTypes:
              - collection:
                  description: The collection.
              - member:
                  description: The member.
            /jobs:
              type: collection
              /status:
                type: member
            /users:
              type: collection
          )
        )
      }
      it 'applies traits to resources' do
        subject.resources.size.should eq 2
        subject.resources.values.each { |resource| mock(resource).apply_traits {} }
        subject.expand
      end
      it 'applies resource types to the resources' do
        subject.resources.size.should eq 2
        subject.resources.values.each { |resource| mock(resource).apply_resource_type {} }
        subject.expand
      end
    end

    context 'when the syntax tree contains resource types and traits' do
      let(:data) {
        YAML.load(
          %q(
            #%RAML 0.8
            title: Example API
            version: v1
            baseUri: https://app.zencoder.com/api
            traits:
              - trait1:
                  queryParameters:
                    param1:
                      description: <<methodName>> trait1 param1
                    param2:
                      description: trait1 param2
                trait2:
                  queryParameters:
                    param2:
                      description: trait2 param2
                    param3:
                      description: trait2 param3 <<arg1 | !pluralize>>
                trait3:
                  queryParameters:
                    param3:
                      description: trait3 param3
                    param4:
                      description: trait3 param4
                trait4:
                  responses:
                    200?:
                      body:
                        application/xml:
                          schema: schema3
                    403?:
                      body:
                        application/xml:
                          schema: schema3
                trait5:
                  responses:
                    403:
                      body:
                        plain/text?:
                          schema: schema4
            resourceTypes:
              - resource_type1:
                  description: resource_type1 description
                  get?:
                    body:
                      application/json:
                        schema: schema1
                  post?:
                    body:
                      application/json:
                        schema: schema2
                resource_type2:
                  description: resource_type2 description
                  displayName: resource_type2 displayName
                  get:
                    is: [ trait1 ]
                    description: resource_type2 get description
            /resource1:
              type: resource_type1
              description: resource1 description
              get:
                description: resource1 get
              /resource1_1:
                type: resource_type2
                description: resource1_1 description
            /resource2:
              type: resource_type2
              is: [ trait3, trait2: { arg1: dog }, trait4, trait5 ]
              get:
                responses:
                  403:
                    body:
                      application/json:
                        schema: schema4
          )
        )
      }

      it 'applies them correctly' do
        subject.expand
        subject.resources['/resource1'].description.should eq 'resource1 description'
        subject.resources['/resource1'].methods.keys.should include 'get'
        subject.resources['/resource1'].methods['get'].bodies['application/json'].schema.value.should eq 'schema1'
        subject.resources['/resource1'].methods.keys.should_not include 'post'
        subject.resources['/resource1'].resources['/resource1_1'].description.should eq 'resource1_1 description'
        subject.resources['/resource1'].resources['/resource1_1'].display_name.should eq 'resource_type2 displayName'
        subject.resources['/resource1'].resources['/resource1_1'].methods['get'].description.should eq 'resource_type2 get description'
        subject.resources['/resource2'].description.should eq 'resource_type2 description'
        subject.resources['/resource2'].display_name.should eq 'resource_type2 displayName'
        subject.resources['/resource2'].methods['get'].description.should eq 'resource_type2 get description'
        subject.resources['/resource2'].methods['get'].query_parameters['param1'].description.should eq 'get trait1 param1'
        subject.resources['/resource2'].methods['get'].query_parameters['param2'].description.should eq 'trait1 param2'
        subject.resources['/resource2'].methods['get'].query_parameters['param3'].description.should eq 'trait2 param3 dogs'
        subject.resources['/resource2'].methods['get'].query_parameters['param4'].description.should eq 'trait3 param4'
        subject.resources['/resource2'].methods['get'].responses.keys.should_not include '200'
        subject.resources['/resource2'].methods['get'].responses.keys.should_not include  200
        subject.resources['/resource2'].methods['get'].responses[403].bodies['application/xml'].schema.value.should eq 'schema3'
        subject.resources['/resource2'].methods['get'].responses[403].bodies.keys.should_not include 'plain/text'
      end
    end

    context 'when parsing large specs' do
      subject { Raml::Parser.parse( File.open("test/apis/#{api_file}").read ) }
      context 'when parsing the Twitter API' do
        let(:api_file) { 'twitter-rest-api.raml' }
        it { expect { subject.expand }.to_not raise_error }
      end
      context 'when parsing the Stripe API' do
        let(:api_file) { 'stripe-api.raml' }
        it { expect { subject.expand }.to_not raise_error }
      end
      context 'when parsing the Twilio API' do
        let(:api_file) { 'twilio-rest-api.raml' }
        it { expect { subject.expand }.to_not raise_error }
      end
      context 'when parsing the Box API' do
        let(:api_file) { 'box-api.raml' }
        it { expect { subject.expand }.to_not raise_error }
      end
      context 'when parsing the Instagram API' do
        let(:api_file) { 'instagram-api.raml' }
        it { expect { subject.expand }.to_not raise_error }
      end
    end
  end
end
