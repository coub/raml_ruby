require_relative 'spec_helper'

describe Raml::Header do
  let (:data) {
    YAML.load(%q(
      Zencoder-Api-Key:
        displayName: ZEncoder API Key
      x-Zencoder-job-metadata-{*}:
        displayName: Job Metadata
        description: |
           Field names prefixed with x-Zencoder-job-metadata- contain user-specified metadata.
           The API does not validate or use this data. All metadata headers will be stored
           with the job and returned to the client when this resource is queried.
    ))
  }

  it "should instanciate Header" do
    Raml::Header.new(data)
  end
end
