require_relative '../spec_helper'

describe Raml::Parameter::FormParameter do
  let (:data) {
    YAML.load(%q(
      AWSAccessKeyId:
        description: The AWS Access Key ID of the owner of the bucket who grants ...
        type: string
      acl:
        description: Specifies an Amazon S3 access control list...
        type: string
      file:
        - type: string
          description: Text content. The text content must be the last field in the form.
        - type: file
          description: File to upload. The file must be the last field in the form.
    ))
  }

  it "should instanciate Form parameter" do
    Raml::Parameter::FormParameter.new(data)
  end
end
