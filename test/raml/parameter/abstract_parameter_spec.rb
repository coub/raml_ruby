require_relative '../spec_helper'

describe Raml::Parameter::AbstractParameter do
  describe "#new" do
    it "should initialize " do
      param_data = {
        type: "integer",
        required: true,
        example: 253995,
        minLength: 33
      }

      param = Raml::Parameter::AbstractParameter.new(param_data)
      # binding.pry
    end
  end

end
