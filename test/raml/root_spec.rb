  require_relative 'spec_helper'

describe Raml::Root do
  let (:data) {
    YAML.load(
      %q(
        #%RAML 0.8
        ---
        title: ZEncoder API
        baseUri: https://app.zencoder.com/api
        documentation:
         - title: Home
           content: |
             Welcome to the _Zencoder API_ Documentation. The _Zencoder API_
             allows you to connect your application to our encoding service
      )
    )
  }

  it "should init root" do
    expect { Root.new(data) }.to_not raise_error
  end


  it "should throw error if title is missing" do
    expect{ Raml::Root.new( { } ) }.to raise_error
  end

  it "should throw error if baseUri is missing" do
    expect{ Raml::Root.new( { } ) }.to raise_error
  end
end
