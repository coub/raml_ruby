require_relative '../spec_helper'

describe Raml::Parameter::QueryParameter do
  let (:data) {
    YAML.load(%q(
      page:
        type: integer
      per_page:
        type: integer
    ))
  }

  it "should instanciate Query parameter" do
    Raml::Parameter::QueryParameter.new(data)
  end
end
