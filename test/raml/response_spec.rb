require_relative 'spec_helper'

describe Raml::Response do
  let (:data) {
    YAML.load(%q(
      description: |
        The service is currently unavailable or you exceeded the maximum requests
        per hour allowed to your application.
      body:
        application/json:
          schema: !include instagram-v1-meta-error.schema.json
    ))
  }

  it "should instanciate Response" do
    Raml::Response.new(data)
  end
end
