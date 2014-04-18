  require_relative 'spec_helper'

describe Raml::Root do

  it "should throw error if title is missing" do
    expect{ Raml::Root.new( { } ) }.to raise_error
  end

  it "should throw error if baseUri is missing" do
    expect{ Raml::Root.new( { } ) }.to raise_error
  end
end
