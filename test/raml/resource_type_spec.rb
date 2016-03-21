# encoding: UTF-8
require_relative 'spec_helper'

describe Raml::ResourceType do
  let(:name) { 'auditableResource' }
  let(:data) {
    YAML.load(%q(
      post:
        body:
          application/x-www-form-urlencoded:
            formParameters:
              createAuthority:
                description: |
                  If the resource has a post method defined, expect a createAuthority
                  property in its body
      delete:
        body:
          multipart/form-data:
            formParameters:
              deleteAuthority:
                description: |
                  If the resource has a delete method defined, expect a deleteAuthority
                  property in its body
    ))
  }
  let(:root) { Raml::Root.new 'title' => 'x', 'baseUri' => 'http://foo.com' }

  subject { Raml::ResourceType.new(name, data, root) }

  describe '#new' do
    context 'with valid arguments' do
      it { expect { subject }.to_not raise_error }
      it { should be_a Raml::ResourceType }
    end
  end

  describe '#instantiate' do
    context 'when the usage property is given' do
      before { data['usage'] = 'Some text' }
      it 'stores the usage property' do
        subject.instantiate({}).usage.should eq data['usage']
      end
    end
    context 'with invalid arguments' do
      context 'when the resource type has nested resources' do
        before { data['/foo'] = {} }
        it { expect { subject.instantiate({}) }.to raise_error Raml::UnknownProperty, /\/foo/ }
      end
    end
  end
end
