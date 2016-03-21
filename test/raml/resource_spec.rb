# encoding: UTF-8
require_relative 'spec_helper'

describe Raml::Resource do
  let(:name) { '/{id}' }
  let(:data) {
    YAML.load(%q(
      uriParameters:
        id:
          type: integer
          required: true
          example: 277102
      /processing_status:
        get:
          displayName: Processing status
          description: Получить статус загрузки
          responses:
            200:
              body:
                application/json:
                  example: |
                    {
                      "percent": 0,
                      "type": "download",
                      "status":"initial"
                    }
    ))
  }
  let(:root_data) { {'title' => 'x', 'baseUri' => 'http://foo.com'} }
  let(:root) { Raml::Root.new root_data }

  subject { Raml::Resource.new(name, data, root) }

  describe '#new' do
    it "should instanciate Resource" do
      subject
    end

    context 'when displayName is given' do
      let(:data) { { 'displayName' => 'My Name', 'description' => 'foo' } }
      it { expect { subject }.to_not raise_error }
      it 'should store the value' do
        subject.display_name.should eq data['displayName']
      end
    end

    context 'when description is not given' do
      let(:data) { {} }
      it { expect { subject }.to_not raise_error }
    end
    context 'when description is given' do
      context 'when the description property is not a string' do
        let(:data) { { 'description' => 1 } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /description/ }
      end
      context 'when the description property is a string' do
        let(:data) { { 'description' => 'My Description'} }
        it { expect { subject }.to_not raise_error }
        it 'should store the value' do
          subject.description.should eq data['description']
        end
      end
    end

    context 'when the uriParameters parameter is given with valid parameters' do
      context 'when the uriParameters property is well formed' do
        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Parameter::UriParameter instances' do
          expect( subject.uri_parameters.values ).to all( be_a Raml::Parameter::UriParameter )
        end
      end
      context 'when the uriParameters property is not a map' do
        let(:data) { { 'uriParameters' => 1 } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /uriParameters/ }
      end
      context 'when the uriParameters property is not a map with non-string keys' do
        let(:data) { { 'uriParameters' => { 1 => {}} } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /uriParameters/ }
      end
      context 'when the uriParameters property is not a map with non-string keys' do
        let(:data) { { 'uriParameters' => { '1' => 'x'} } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /uriParameters/ }
      end
    end

    context 'when nested resources are defined' do
      let(:name) { '/{userId}' }
      let(:data) {
        YAML.load(
          %q(
            uriParameters:
              userId:
                type: integer
            /followers:
              displayName: Followers
            /following:
              displayName: Following
            /keys:
              /{keyId}:
                uriParameters:
                  keyId:
                    type: integer
          )
        )
      }
      it { expect { subject }.to_not raise_error }
      it 'stores all as Raml::Resource instances' do
        expect( subject.resources.values ).to all( be_a Raml::Resource )
        expect( subject.resources.keys   ).to contain_exactly('/followers','/following', '/keys')
      end
    end

    context 'when a baseUriParameters property is given' do
      context 'when the baseUriParameters property is well formed' do
        let(:name) { '/files' }
        let(:data) {
          YAML.load(
            %q(
              displayName: Download files
              baseUriParameters:
                apiDomain:
                  enum: [ "api-content" ]
            )
          )
        }

        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Parameter::UriParameter instances' do
          expect( subject.base_uri_parameters.values ).to all( be_a Raml::Parameter::BaseUriParameter )
          subject.base_uri_parameters.keys.should contain_exactly('apiDomain')
        end
      end
      context 'when the baseUriParameters property is not a map' do
        before { data['baseUriParameters'] = 1 }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /baseUriParameters/ }
      end
      context 'when the baseUriParameters property is not a map with non-string keys' do
        before { data['baseUriParameters'] = { 1 => {}} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /baseUriParameters/ }
      end
      context 'when the baseUriParameters property is not a map with non-string keys' do
        before { data['baseUriParameters'] = { '1' => 'x'} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /baseUriParameters/ }
      end
      context 'when the baseUriParameters property has a key for the reserved "version" parameter' do
        before { data['baseUriParameters'] = { 'version' => {}} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /baseUriParameters/ }
      end
    end

    context 'when an type property is given' do
     let(:root) {
        Raml::Root.new 'title' => 'x', 'baseUri' => 'http://foo.com',  'resourceTypes' => [
          { 'collection'        => {} },
          { 'member'            => {} },
          { 'auditableResource' => {} }
        ]
      }
      context 'when the property is valid' do
        context 'when the property is a resource type reference' do
          before { data['type'] = 'collection' }
          it { expect { subject }.to_not raise_error }
          it 'should store the resource type reference' do
            subject.type.should be_a Raml::ResourceTypeReference
            subject.type.name.should == 'collection'
          end
        end
        context 'when the property is a resource type reference with parameters' do
          before { data['type'] = {'collection' => {'maxSize' => 10}} }
          it { expect { subject }.to_not raise_error }
          it 'should store the resource type reference' do
            subject.type.should be_a Raml::ResourceTypeReference
            subject.type.name.should == 'collection'
          end
        end
        context 'when the property is a resource type definitions' do
          let(:definition) {
            YAML.load(%q(
              usage: This resourceType should be used for any collection of items
              description: The collection of <<resourcePathName>>
              get:
                description: Get all <<resourcePathName>>, optionally filtered
            ))
          }
          before { data['type'] = definition }

          it { expect { subject }.to_not raise_error }
          it 'should store the resource type' do
            subject.type.should be_a Raml::ResourceType
            subject.send(:instantiate_resource_type).usage.should == definition['usage']
          end
        end
      end
      context 'when the property is invalid' do
        context 'when the type property is not a string or a map' do
          before { data['type'] = 1 }
          it { expect { subject }.to raise_error Raml::InvalidProperty, /type/ }
        end
        context 'when the property is a resource type name with parameters, but the params are not a map' do
          before { data['type'] = { 'collection' => 1 } }
          it { expect { subject }.to raise_error Raml::InvalidProperty, /type/ }
        end
      end
    end

    context 'when an is property is given' do
     let(:root) {
        Raml::Root.new 'title' => 'x', 'baseUri' => 'http://foo.com',  'traits' => [
          { 'secured'     => {} },
          { 'paged'       => {} },
          { 'rateLimited' => {} }
        ]
      }
      context 'when the property is valid' do
        context 'when the property is an array of trait references' do
          let(:data) { { 'is' => [ 'secured', 'paged' ] } }
          it { expect { subject }.to_not raise_error }
          it 'should store the trait references' do
            subject.traits.should all( be_a Raml::TraitReference )
            subject.traits.map(&:name).should contain_exactly('secured', 'paged')
          end
        end
        context 'when the property is an array of trait references with parameters' do
          let(:data) { {
            'is' => [
              {'secured' => {'tokenName' => 'access_token'}},
              {'paged'   => {'maxPages'  => 10            }}
            ]
          } }
          it { expect { subject }.to_not raise_error }
          it 'should store the trait references' do
            subject.traits.should all( be_a Raml::TraitReference )
            subject.traits.map(&:name).should contain_exactly('secured', 'paged')
          end
        end
        context 'when the property is an array of trait definitions' do
          let(:data) { {
            'is' => [
              {'queryParameters' => {'tokenName' => {'description'=>'foo'}}},
              {'queryParameters' => {'numPages'  => {'description'=>'bar'}}}
            ]
          } }
          it { expect { subject }.to_not raise_error }
          it 'should store the traits' do
            subject.traits.should all( be_a Raml::Trait )
            subject.traits[0].value.should eq ({'queryParameters' => {'tokenName' => {'description'=>'foo'}}})
            subject.traits[1].value.should eq ({'queryParameters' => {'numPages'  => {'description'=>'bar'}}})
          end
        end
        context 'when the property is an array of mixed trait refrences, trait refrences with parameters, and trait definitions' do
          let(:data) { {
            'is' => [
              {'secured' => {'tokenName' => 'access_token'}},
              {'queryParameters' => {'numPages'  => {'description'=>'bar'}}},
              'rateLimited'
            ]
          } }
          it { expect { subject }.to_not raise_error }
          it 'should store the traits' do
            subject.traits.select {|t| t.is_a? Raml::TraitReference }.map(&:name).should contain_exactly('secured', 'rateLimited')
            subject.traits.select {|t| t.is_a? Raml::Trait }[0].value.should eq ({'queryParameters' => {'numPages'  => {'description'=>'bar'}}})
          end
        end
      end
      context 'when the property is invalid' do
        context 'when the property is not an array' do
          let(:data) { { 'is' => 1 } }
          it { expect { subject }.to raise_error Raml::InvalidProperty, /is/ }
        end
        context 'when the property is an array with elements other than a string or map' do
          let(:data) { { 'is' => [1] } }
          it { expect { subject }.to raise_error Raml::InvalidProperty, /is/ }
        end
        context 'when the property is an array an element that appears to be a trait name with parameters, but the params are not a map' do
          let(:data) { { 'is' => [ { 'secured' => 1 } ] } }
          it { expect { subject }.to raise_error Raml::InvalidProperty, /is/ }
        end
      end
    end

    context 'when the syntax tree contains optional properties' do
      let(:data) {
        YAML.load(%q(
          uriParameters:
            id:
              type: integer
              required: true
              example: 277102
          /processing_status:
            get:
              displayName: Processing status
              description: Получить статус загрузки
              responses:
                200?:
                  body:
                    application/json:
                      example: |
                        {
                          "percent": 0,
                          "type": "download",
                          "status":"initial"
                        }
        ))
      }
      it { expect { subject }.to raise_error Raml::InvalidProperty, /Optional properties/ }
    end

    context 'when the securedBy property is defined' do
      let (:root_data) { {'title' => 'x', 'baseUri' => 'http://foo.com', 'securitySchemes' => ['oauth_2_0' => {'type' => 'OAuth 2.0'}, 'oauth_1_0' => {'type' => 'OAuth 1.0'}] } }
      context 'when the securedBy property is an array of strings' do
        let(:data) { { 'securedBy' => ['oauth_2_0', 'oauth_1_0'] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the securedBy property is an array of strings and "null"' do
        let(:data) { { 'securedBy' => ['oauth_2_0', 'null'] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the securedBy property is an array of hash with single key' do
        let(:data) { { 'securedBy' => ['oauth_2_0' => {'scopes' => 'ADMINISTRATOR'}] } }
        it { expect{ subject }.to_not raise_error }
      end
      context 'when the securedBy property references a missing security scheme' do
        let(:data) { { 'securedBy' => ['bar'] } }
        it { expect{ subject }.to raise_error Raml::UnknownSecuritySchemeReference, /bar/}
      end
      context 'when the securedBy property is included it is accessible and' do
        let(:data) { { 'securedBy' => ['oauth_2_0', 'oauth_1_0'] } }
        it 'exposes the schema references' do
          expect( subject.secured_by.values ).to all( be_a Raml::SecuritySchemeReference )
          subject.secured_by.keys.should contain_exactly('oauth_2_0', 'oauth_1_0')
        end
      end
    end
  end

  describe '#apply_resource_type' do
    let(:resource_data) { {
      'type' => {
        'get' => { 'description' => 'resource type description', 'displayName' => 'resource type displayName' }
      },
      'get'  => {'description' => 'method description'},
      'post' => {},
      '/foo' => {},
      '/bar/{id}' => {}
    } }
    let(:resource) { Raml::Resource.new('/foo', resource_data, root)  }
    let(:resource_with_parameter) { Raml::Resource.new('/bar/{id}', resource_data, root)  }
    context 'when it has a resource type' do
      it 'merges the resource type to the resource' do
        resource.type.should be_a Raml::ResourceType
        mock.proxy(resource).instantiate_resource_type { |instantiated_type|
          mock(resource).merge(instantiated_type)
          mock(resource).merge(is_a(Raml::Resource))
          instantiated_type
        }
        resource.apply_resource_type
      end
      it 'applies the resource type correctly' do
        resource.apply_resource_type
        resource.methods['get'].description.should  eq 'method description'
        resource.methods['get'].display_name.should eq 'resource type displayName'
        resource.resource_path.should eq '/foo'
        resource.resource_path_name.should eq 'foo'
      end
      it 'sets the resource path name stripping out uri parameters' do
        resource_with_parameter.apply_resource_type
        resource_with_parameter.resource_path_name.should eq 'bar'
      end
    end
    context 'when it has nested resources' do
      it 'calls #apply_resource_type on the nested resources' do
        resource.resources.size.should eq 2
        resource.resources.values.each { |resource| mock(resource).apply_resource_type {} }
        resource.apply_resource_type
      end
    end
  end

  describe '#apply_traits' do
    let(:resource_data) { {
      'is' => [
        { 'description' => 'trait1 description' },
        { 'description' => 'trait2 description' }
      ],
      'get'  => {},
      'post' => {},
      '/foo' => {},
      '/bar' => {}
    } }
    let(:resource) { Raml::Resource.new('/foo', resource_data, root)  }
    it 'calls apply_traits on all its methods' do
      resource.traits.size.should eq 2
      resource.methods.size.should eq 2
      resource.methods.values.each { |method| mock(method).apply_traits {} }
      resource.apply_traits
    end
    it 'should call apply_trait on child resources without the resource traits' do
      resource.traits.size.should eq 2
      resource.resources.size.should eq 2
      resource.resources.values.each { |resource| mock(resource).apply_traits {} }
      resource.apply_traits
    end
  end

  describe '#merge' do
    let(:resource) { Raml::Resource.new('/foo', resource_data, root)  }
    context 'when called with something other than a ResourceType' do
      let(:resource_data) { {} }
      it do
        expect { resource.merge(Raml::ResourceTypeReference.new('bar', root)) }.to raise_error Raml::MergeError
      end
    end
    context 'when called with a ResourceType::Instance' do
      let(:root_data) { {
        'title'   => 'x',
        'baseUri' => 'http://foo.com',
        'traits'  => [ {
          'secured' => { 'usage' => 'requires authentication' },
          'paged'   => { 'usage' => 'allows for paging'       }
        } ]
      } }
      let(:resource_type) { Raml::ResourceType.new('bar', resource_type_data, root).instantiate({})  }
      let(:resource_data) { {
        'is' => [ 'secured' ],
        'baseUriParameters' => { 'apiDomain' => { 'enum' => ['api']   } },
        'uriParameters'     => { 'userId'    => { 'type' => 'integer' } },
        'get' => {
          'queryParameters' => { 'id'        => { 'type' => 'integer' } }
        }
      } }
      let(:resource_type_data) { {
        'usage' => 'resource usage',
        'is'    => [ 'paged' ],
        'baseUriParameters' => { 'apiDomain' => { 'enum'      => ['static'] } },
        'uriParameters'     => { 'language'  => { 'default'   => 'en'       } },
        'get' => {
          'queryParameters' => { 'query'     => { 'maxLength' => 100        } }
        },
        'post' => {
          'description' => 'create a new one'
        }
      } }
      it 'merges the resource type into the resource' do
        resource.merge resource_type
        resource.traits.map { |trait_ref| trait_ref.name }.should eq [ 'paged', 'secured' ]
        resource.base_uri_parameters.keys.should contain_exactly('apiDomain')
        resource.base_uri_parameters['apiDomain'].enum.should eq ['static']
        resource.uri_parameters.keys.should contain_exactly('userId', 'language')
        resource.methods.keys.should contain_exactly('get', 'post')
        resource.methods['get'].query_parameters.keys.should contain_exactly('id', 'query')
      end
      it 'does not add the usage property to the resource' do
        resource.merge resource_type
         expect { resource.usage }.to raise_error NoMethodError
      end
    end
  end
end
