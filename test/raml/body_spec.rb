require_relative 'spec_helper'

describe Raml::Body do
  let (:data) {
    YAML.load(%q(
      body:
        text/xml:
          schema: !include job.xsd
        application/json:
          schema: !include job.schema.json
    ))
  }

  it "should instanciate Body" do
    Raml::Body.new(data)
  end
end
