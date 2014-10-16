require_relative 'spec_helper'

describe Raml::Method do
  let(:name) { 'get' }
  let(:data) {
    YAML.load(%q(
      description: Get a list of users
      queryParameters:
        page:
          description: Specify the page that you want to retrieve
          type: integer
          required: true
          example: 1
        per_page:
          description: Specify the amount of items that will be retrieved per page
          type: integer
          minimum: 10
          maximum: 200
          default: 30
          example: 50
      protocols: [ HTTP, HTTPS ]
      responses:
        200:
          description: |
            The list of popular media.
    ))
  }
  let(:root_data) { {'title' => 'x', 'baseUri' => 'http://foo.com'} }
  let(:root) { Raml::Root.new root_data }

  subject { Raml::Method.new(name, data, root) }

  describe '#new' do
    it "should instanciate Method" do
      subject
    end

    context 'when the method is a method defined in RFC2616 or RFC5789' do
      %w(options get head post put delete trace connect patch).each do |method|
        context "when the method is #{method}" do
          let(:name) { method }
          it { expect { subject }.to_not raise_error }
        end
      end
    end
    context 'when the method is an unsupported method' do
      %w(propfind proppatch mkcol copy move lock unlock).each do |method|
        context "when the method is #{method}" do
          let(:name) { method }
          it { expect { subject }.to raise_error Raml::InvalidMethod }
        end
      end
    end

    context 'when description property is not given' do
      let(:data) { {} }
      it { expect { subject }.to_not raise_error }
    end
    context 'when description property is given' do
      context 'when the description property is not a string' do
        let(:data) { { 'description' => 1 } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /description/ }
      end
      context 'when the description property is a string' do
        let(:data) { { 'description' => 'My Description' } }
        it { expect { subject }.to_not raise_error }
        it 'should store the value' do
          subject.description.should eq data['description']
        end
      end
    end

    context 'when the headers parameter is given' do
      context 'when the headers property is well formed' do
        let (:data) {
          YAML.load(%q(
            headers:
              Zencoder-Api-Key:
                displayName: ZEncoder API Key
              x-Zencoder-job-metadata-{*}:
                displayName: Job Metadata
          ))
        }
        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Header instances' do
          expect( subject.headers.values ).to all( be_a Raml::Header )
          expect( subject.headers.keys   ).to contain_exactly('Zencoder-Api-Key','x-Zencoder-job-metadata-{*}')
        end
      end
      context 'when the headers property is not a map' do
        let(:data) { { 'headers' => 1 } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /headers/ }
      end
      context 'when the headers property is not a map with non-string keys' do
        let(:data) { { 'headers' => { 1 => {}} } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /headers/ }
      end
      context 'when the headers property is not a map with non-string keys' do
        let(:data) { { 'headers' => { '1' => 'x'} } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /headers/ }
      end
    end

    context 'when the protocols property is missing' do
      let(:data) { { } }
      it { expect{ subject }.to_not raise_error }
    end
    context 'when the protocols property is given' do
      context 'when the protocol property is not an array' do
        let(:data) { { 'protocols' => 'HTTP' } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /protocols/ }
      end
      context 'when the protocol property is an array but not all elements are strings' do
        let(:data) { { 'protocols' => ['HTTP', 1] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /protocols/ }
      end
      context 'when the protocol property is an array of strings with invalid values' do
        let(:data) { { 'protocols' => ['HTTP', 'foo'] } }
        it { expect{ subject }.to raise_error Raml::InvalidProperty, /protocols/ }
      end
      [
        [ 'HTTP'  ],
        [ 'HTTPS' ],
        [ 'HTTP', 'HTTPS' ]
      ].each do |protocols|
        context "when the protocol property is #{protocols}" do
          let(:data) { { 'protocols' => protocols } }
          it { expect{ subject }.to_not raise_error }
          it 'stores the values' do
            subject.protocols.should eq protocols
          end
        end
      end
      context 'when the protocol property is an array of valid values in lowercase' do
        let(:data) { { 'protocols' => ['http', 'https'] } }
        it 'uppercases them' do
          subject.protocols.should eq [ 'HTTP', 'HTTPS' ]
        end
      end
    end

    context 'when a queryParameters property is given' do
      context 'when the queryParameters property is well formed' do
        let(:data) {
          YAML.load(
            %q(
              description: Get a list of users
              queryParameters:
                page:
                  description: Specify the page that you want to retrieve
                  type: integer
                  required: true
                  example: 1
                per_page:
                  description: Specify the amount of items that will be retrieved per page
                  type: integer
                  minimum: 10
                  maximum: 200
                  default: 30
                  example: 50
            )
          )
        }

        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Parameter::UriParameter instances' do
          expect( subject.query_parameters.values ).to all( be_a Raml::Parameter::QueryParameter )
          subject.query_parameters.keys.should contain_exactly('page', 'per_page')
        end
      end
      context 'when the queryParameters property is not a map' do
        before { data['queryParameters'] = 1 }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /queryParameters/ }
      end
      context 'when the queryParameters property is not a map with non-string keys' do
        before { data['queryParameters'] = { 1 => {}} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /queryParameters/ }
      end
      context 'when the queryParameters property is not a map with non-string keys' do
        before { data['queryParameters'] = { '1' => 'x'} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /queryParameters/ }
      end
    end

    context 'when a body property is given' do
      context 'when the body property is well formed' do
        let(:data) {
          YAML.load(
            %q(
            description: Create a Job
            body:
              text/xml:
                schema: job_xml_schema
              application/json:
                schema: json_xml_schema
            )
          )
        }

        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Body instances' do
          expect( subject.bodies.values ).to all( be_a Raml::Body )
          subject.bodies.keys.should contain_exactly('text/xml', 'application/json')
        end
      end
      context 'when the body property is not a map' do
        before { data['body'] = 1 }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /body/ }
      end
      context 'when the body property is a map with non-string keys' do
        before { data['body'] = { 1 => {}} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /body/ }
      end
      context 'when the body property is a map with non-map values' do
        before { data['body'] = { 'text/xml' => 1 } }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /body/ }
      end
    end

    context 'when a responses property is given' do
      context 'when the responses property is well formed' do
        let(:data) {
          YAML.load(
            %q(
              responses:
                200:
                  body:
                    application/json:
                      example: !include examples/instagram-v1-media-popular-example.json
                503:
                  description: The service is currently unavailable.
            )
          )
        }

        it { expect { subject }.to_not raise_error }
        it 'stores all as Raml::Response instances' do
          expect( subject.responses.values ).to all( be_a Raml::Response )
          subject.responses.keys.should contain_exactly(200, 503)
        end
      end
      context 'when the responses property is not a map' do
        before { data['responses'] = 1 }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /responses/ }
      end
      context 'when the responses property is not a map with string integer keys' do
        before { data['responses'] = { '200' => {}} }
        it { expect { subject }.not_to raise_error }
      end
      context 'when the responses property is not a map with non-string keys' do
        before { data['responses'] = { 200 => 'x'} }
        it { expect { subject }.to raise_error Raml::InvalidProperty, /responses/ }
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
            subject.traits.select {|t| t.is_a? Raml::Trait}[0].value.should eq ({'queryParameters' => {'numPages'  => {'description'=>'bar'}}})
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
          description: Get a list of users
          queryParameters:
            page?:
              description: Specify the page that you want to retrieve
              type: integer
              required: true
              example: 1
          protocols: [ HTTP, HTTPS ]
          responses:
            200:
              description: |
                The list of popular media.
        ))
      }
      it { expect {subject }.to raise_error Raml::InvalidProperty, /Optional properties/ }
    end
  end

  describe '#merge' do
    let(:method) { Raml::Method.new 'get'       , method_data, root }
    let(:trait ) { Raml::Trait.new( 'trait_name', trait_data , root).instantiate({}) }
    context 'when the trait has a property set' do
      context 'when the method does not have that property set' do
        let(:method_data) { {} }
        context 'description property' do
          let(:trait_data) { {description: 'trait description'} }
          it 'sets the property in the method' do
            method.merge(trait).description.should eq trait.description
          end
        end
        context 'protocols property' do
          let(:trait_data) { {protocols: ['HTTPS']} }
          it 'sets the property in the method' do
            method.merge(trait).protocols.should eq trait.protocols
          end
        end
        context 'headers properties' do
          let(:trait_data) { {
            'headers' => {
              'header1' => {'description' => 'foo'},
              'header2' => {'description' => 'bar'}
            }
          } }
          it 'adds the headers to the method' do
             method.merge(trait).headers.keys.should contain_exactly('header1', 'header2')
          end
        end
        context 'queryParameters properties' do
          let(:trait_data) { {
            'queryParameters' => {
              'param1' => {'description' => 'foo'},
              'param2' => {'description' => 'bar'}
            }
          } }
          it 'adds the headers to the method' do
             method.merge(trait).query_parameters.keys.should contain_exactly('param1', 'param2')
          end
        end
        context 'body property' do
          let(:trait_data) { {
            'body' => {
              'text/mime1' => {'schema' => 'foo'},
              'text/mime2' => {'schema' => 'bar'}
            }
          } }
          it 'adds the body media types to the method' do
             method.merge(trait).bodies.keys.should contain_exactly('text/mime1', 'text/mime2')
          end
        end
        context 'responses property' do
          let(:trait_data) { {
            'responses' => {
              200 => {'description' => 'foo'},
              404 => {'description' => 'bar'}
            }
          } }
          it 'adds the responses to the method' do
             method.merge(trait).responses.keys.should contain_exactly(200, 404)
          end
        end
        context 'usage property' do
          let(:trait_data) { { 'usage' => 'trait usage' } }
          it 'does not add the usage property to the method' do
             method.merge(trait)
             expect { method.usage }.to raise_error NoMethodError
          end
        end
      end
      context 'when the method has that property set' do
        context 'description property' do
          let(:method_data) { {description: 'method description'} }
          let(:trait_data ) { {description: 'trait description' } }
          it 'overwrites the method property' do
            method.merge(trait).description.should eq 'trait description'
          end
        end
        context 'protocols property' do
          let(:method_data) { {protocols: ['HTTP' ]} }
          let(:trait_data ) { {protocols: ['HTTPS']} }
          it 'overwrites the method property' do
            method.merge(trait).protocols.should eq ['HTTPS']
          end
        end
        context 'headers properties' do
          let(:method_data) { {
            'headers' => {
              'header1' => {'description' => 'foo'},
              'header2' => {'description' => 'bar'}
            }
          } }
          context 'when the trait headers are different from the method headers' do
            let(:trait_data) { {
              'headers' => {
                'header3' => {'description' => 'foo2'},
                'header4' => {'description' => 'bar2'}
              }
            } }
            it 'adds the headers to the method' do
               method.merge(trait).headers.keys.should contain_exactly('header1', 'header2', 'header3', 'header4')
            end
          end
          context 'when the trait headers overlap the the method headers' do
            let(:trait_data) { {
              'headers' => {
                'header2' => {'displayName' => 'Header 3'},
                'header3' => {'description' => 'foo2'},
                'header4' => {'description' => 'bar2'}
              }
            } }
            it 'merges the matching headers and adds the non-matching headers to the method' do
               method.merge(trait).headers.keys.should contain_exactly('header1', 'header2', 'header3', 'header4')
               method.headers['header2'].display_name.should eq trait.headers['header2'].display_name
            end
          end
        end
        context 'queryParameters properties' do
          let(:method_data) { {
            'queryParameters' => {
              'param1' => {'description' => 'foo'},
              'param2' => {'description' => 'bar'}
            }
          } }
          context 'when the trait query parameters are different from the method headers' do
            let(:trait_data) { {
              'queryParameters' => {
                'param3' => {'description' => 'foo2'},
                'param4' => {'description' => 'bar2'}
              }
            } }
            it 'adds the query parameters to the method' do
               method.merge(trait).query_parameters.keys.should contain_exactly('param1', 'param2', 'param3', 'param4')
            end
          end
          context 'when the trait query parameters overlap the the method query parameters' do
            let(:trait_data) { {
              'queryParameters' => {
                'param2' => {'displayName' => 'Param 3'},
                'param3' => {'description' => 'foo2'},
                'param4' => {'description' => 'bar2'}
              }
            } }
            it 'merges the matching headers and adds the non-matching headers to the method' do
               method.merge(trait).query_parameters.keys.should contain_exactly('param1', 'param2', 'param3', 'param4')
               method.query_parameters['param2'].display_name.should eq trait.query_parameters['param2'].display_name
            end
          end
        end
        context 'body property' do
          let(:method_data) { {
            'body' => {
              'text/mime1' => {'schema' => 'foo'},
              'text/mime2' => {'schema' => 'bar'}
            }
          } }
          context 'when the trait query parameters are different from the method headers' do
            let(:trait_data) { {
              'body' => {
                'text/mime3' => {'schema' => 'foo2'},
                'text/mime4' => {'schema' => 'bar2'}
              }
            } }
            it 'adds the body media types to the method' do
               method.merge(trait).bodies.keys.should contain_exactly('text/mime1', 'text/mime2', 'text/mime3', 'text/mime4')
            end
          end
          context 'when the trait query parameters overlap the the method query parameters' do
            let(:trait_data) { {
              'body' => {
                'text/mime2' => {'example' => 'Example 2'},
                'text/mime3' => {'schema'  => 'foo2'},
                'text/mime4' => {'schema'  => 'bar2'}
              }
            } }
            it 'merges the matching media types and adds the non-matching media types to the method' do
               method.merge(trait).bodies.keys.should contain_exactly('text/mime1', 'text/mime2', 'text/mime3', 'text/mime4')
               method.bodies['text/mime2'].example.should eq trait.bodies['text/mime2'].example
            end
          end
        end
        context 'responses property' do
          let(:method_data) { {
            'responses' => {
              200 => {'description' => 'foo', 'body' => { 'text/mime1' => {'schema' => 'schema1'} } },
              404 => {'description' => 'bar'}
            }
          } }
          context 'when the trait response status codes are different from the method responses status codes' do
            let(:trait_data) { {
              'responses' => {
                201 => {'description' => 'foo2'},
                403 => {'description' => 'bar2'}
              }
            } }
            it 'adds the body media types to the method' do
               method.merge(trait).responses.keys.should contain_exactly(200, 404, 201, 403)
            end
          end
          context 'when the trait query parameters overlap the the method query parameters' do
            let(:trait_data) { {
              'responses' => {
                200 => {'description' => 'foo', 'body' => { 'text/mime2' => {'schema' => 'schema2'} } },
                201 => {'description' => 'foo2'},
                403 => {'description' => 'bar2'}
              }
            } }
            it 'merges the matching media types and adds the non-matching media types to the method' do
               method.merge(trait).responses.keys.should contain_exactly(200, 404, 201, 403)
               method.responses[200].bodies.keys.should contain_exactly('text/mime1', 'text/mime2')
            end
          end
        end
      end
    end
  end

  describe '#apply_traits' do
    let(:root_data) { {
      'title'   => 'x',
      'baseUri' => 'http://foo.com',
      '/users'  => {
        '/comments' => {
          'is'  => resource_trait_data,
          'get' => method_data
        }
      }
    } }
    let(:method) { root.resources['/users'].resources['/comments'].methods['get'] }
    before {  method.apply_traits }
    describe 'order application' do
      context 'when given no resource traits' do
        let(:resource_trait_data) { [] }
        context 'when method has a trait' do
          let(:method_data) { { 'is' => [ { 'description' => 'trait description' } ] } }
          it 'applies the method trait' do
            method.description.should eq 'trait description'
          end
        end
        context 'when the method has multiple traits' do
          let(:method_data) { {
            'is' => [
              {
                'description' => 'trait description',
                'headers'     => { 'header1' => { 'description' => 'header1' } }
              },
              {
                'description' => 'trait description 2',
                'headers'     => { 'header2' => { 'description' => 'header2' } }
              }
            ]
          } }
          it 'applies them in order of precedence, right to left' do
            method.description.should eq 'trait description 2'
            method.headers.keys.should contain_exactly('header1', 'header2')
          end
        end
      end
      context 'when given resource traits' do
        let(:resource_trait_data) { [ { 'description' => 'resource trait description' } ] }
        context 'when the method has no traits' do
          let(:method_data) { {} }
          it 'applies the resource trait' do
            method.description.should eq 'resource trait description'
          end
        end
        context 'when the method has traits' do
          let(:resource_trait_data) {
            [
              {
                'description' => 'trait4 description',
                'headers'     => {
                  'header3' => { 'description' => 'trait4' },
                  'header4' => { 'description' => 'trait4' }
                }
              },
              {
                'description' => 'trait3 description',
                'headers'     => {
                  'header2' => { 'description' => 'trait3' },
                  'header3' => { 'description' => 'trait3' }
                }
              }
            ]
          }
          let(:method_data) { {
            'description' => 'method description',
            'is' => [
              {
                'description' => 'trait2 description',
                'headers'     => {
                  'header1' => { 'description' => 'trait2' },
                  'header2' => { 'description' => 'trait2' }
                }
              },
              {
                'description' => 'trait1 description',
                'headers'     => {
                  'header1' => { 'description' => 'trait1' }
                }
              }
            ]
          } }
          it 'applies method traits first in reverse order, then resource traits in reverse order' do
            method.description.should eq 'method description'
            method.headers.keys.should contain_exactly('header1','header2', 'header3', 'header4')
            method.headers['header1'].description.should eq 'trait1'
            method.headers['header2'].description.should eq 'trait2'
            method.headers['header3'].description.should eq 'trait3'
            method.headers['header4'].description.should eq 'trait4'
          end
        end
      end
    end
    describe 'reserved parameters' do
      let(:resource_trait_data) { [] }
      context 'resourcePath' do
        let(:method_data) { { 'is' => [ { 'description' => 'trait <<resourcePath>>' } ] } }
        it 'instances traits with the reserved parameter' do
          method.description.should eq 'trait /users/comments'
        end
      end
      context 'resourcePathName' do
        let(:method_data) { { 'is' => [ { 'description' => 'trait <<resourcePathName>>' } ] } }
        it 'instances traits with the reserved parameter' do
          method.description.should eq 'trait comments'
        end
      end
      context 'methodName' do
        let(:method_data) { { 'is' => [ { 'description' => 'trait <<methodName>>' } ] } }
        it 'instances traits with the reserved parameter' do
          method.description.should eq 'trait get'
        end
      end
    end
  end
end
