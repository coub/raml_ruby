# encoding: UTF-8
require_relative 'spec_helper'

describe Raml::SecurityScheme do
  let(:name) { 'oauth_2_0' }
  let(:data) {
    YAML.load(%q(
      description: |
          Dropbox supports OAuth 2.0 for authenticating all API requests.
      type: OAuth 2.0
      describedBy:
          headers:
              Authorization:
                  description: |
                      Used to send a valid OAuth 2 access token. Do not use
                      with the "access_token" query string parameter.
                  type: string
          queryParameters:
              access_token:
                  description: |
                      Used to send a valid OAuth 2 access token. Do not use together with
                      the "Authorization" header
                  type: string
          responses:
              401:
                  description: |
                      Bad or expired token. This can happen if the user or Dropbox
                      revoked or expired an access token. To fix, you should re-
                      authenticate the user.
              403:
                  description: |
                      Bad OAuth request (wrong consumer key, bad nonce, expired
                      timestamp...). Unfortunately, re-authenticating the user won't help here.
      settings:
          authorizationUri: https://www.dropbox.com/1/oauth2/authorize
          accessTokenUri: https://api.dropbox.com/1/oauth2/token
          authorizationGrants: [ code, token ]
    ))
  }
  let(:root) { Raml::Root.new 'title' => 'x', 'baseUri' => 'http://foo.com' }

  subject { Raml::SecurityScheme.new(name, data, root) }

  describe '#new' do
    context 'with valid arguments' do
      it { expect { subject }.to_not raise_error }
      it { should be_a Raml::SecurityScheme }
    end
  end

  describe '#instantiate' do
    context 'when the description property is given' do
      before { data['description'] = 'Some text' }
      it 'stores the description property' do
        subject.instantiate({}).description.should eq data['description']
      end
    end
    context 'when the type property is given' do
      before { data['type'] = 'Some text' }
      it 'stores the type property' do
        subject.instantiate({}).type.should eq data['type']
      end
    end
    context 'with invalid arguments' do
      context 'when the securityScheme has nested resources' do
        before { data['/foo'] = {} }
        it { expect { subject.instantiate({}) }.to raise_error Raml::UnknownProperty, /\/foo/ }
      end
    end
  end
end
