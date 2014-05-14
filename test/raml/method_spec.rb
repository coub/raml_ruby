require_relative 'spec_helper'

describe Raml::Method do
  let(:name) { 'get' }
  let (:data) {
    YAML.load(%q(
      description: Get a list of users
      queryParameters:
        page:
          description: Specify the page that you want to retrieve
          type: integer
          required: true
          example: 1
        per_page:
          description: Specify the amount of items that will be retrieved per page
          type: integer
          minimum: 10
          maximum: 200
          default: 30
          example: 50
      protocols: [ HTTP, HTTPS ]
      responses:
        200:
          description: |
            The list of popular media.
    ))
  }

  subject { Raml::Method.new(name, data) }

  it "should instanciate Method" do
    subject
  end

  describe "#document" do
    it "prints out documentation" do
      subject.document

      # puts subject.document
    end

  end
end
