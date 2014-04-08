require_relative '../spec_helper'

describe Raml::Parameter::UriParameter do
  let (:data) {
    YAML.load(%q(
      uriParameters:
        AccountSid:
          description: |
            An Account instance resource represents a single Twilio account.
          type: string
    ))
  }

  it "should instanciate Uri parameter" do
    Raml::Parameter::UriParameter.new(data)
  end




end
