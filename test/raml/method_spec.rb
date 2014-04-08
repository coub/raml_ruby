require_relative 'spec_helper'

describe Raml::Method do
  let (:data) {
    YAML.load(%q(
      description: Returns a collection of relevant Tweets matching a specified query
      protocols: [HTTP, HTTPS]
    ))
  }

  it "should instanciate Method" do
    Raml::Method.new(data)
  end
end
