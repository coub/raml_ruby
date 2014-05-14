require_relative '../spec_helper'

describe Raml::Parameter::QueryParameter do
  let(:name) { 'page' }
  let(:data) {
    YAML.load(%q(
      page:
        type: integer
      per_page:
        type: integer
    ))
  }

  subject { Raml::Parameter::QueryParameter.new(name, data) }

  it "should instanciate Query parameter" do
    Raml::Parameter::QueryParameter.new(name, data)
  end

  describe "#document" do
    let(:data) {
      YAML.load(%q(
        description: Specify the page that you want to retrieve
        type: integer
        required: true
        example: 1
      ))
    }

    it "prints out documentation" do
      subject.document

      # puts "\n"
      # puts subject.document
      # puts "\n"
    end
  end
end
