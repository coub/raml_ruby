require_relative '../spec_helper'

describe Raml::Parameter::AbstractParameter do
  describe '#new' do
    let(:abstract_param_class) { Raml::Parameter::AbstractParameter }
    let(:name) { 'page_number' }

    it 'should initialize ' do

      param_data = {
        type: 'integer',
        required: true,
        example: 253995,
        minimum: 33
      }

      param = abstract_param_class.new(name, param_data)
      param.name.should == name
    end

    it 'should default parameter type to string' do
      param = abstract_param_class.new(name, { required: true })
      param.type.should == 'string'
    end

    describe 'valid parameter types' do
      Raml::Parameter::AbstractParameter::VALID_TYPES.each do |type|
        it "should allow type #{type}" do
          param = abstract_param_class.new(name, { type: type })
          param.type.should == type
        end
      end

      it 'should throw error if type is invalid' do
        invalid_type = 'unicorn'
        expect { abstract_param_class.new(name, { type: invalid_type }) }.
        to raise_error
      end
    end

    describe "minLength / maxLength" do
      it 'should throw warning if minLength applied to non string type' do
        expect { abstract_param_class.new(name, { type: 'integer', min_length: 2 }) }.
        to raise_error
      end

      it 'should throw warning if maxLength applied to non string type' do
        expect { abstract_param_class.new(name, { type: 'integer', max_length: 2 }) }.
        to raise_error
      end
    end

    describe 'minimum / maximum' do
      %w(minimum maximum).each do |attribute|
        it "should throw warning if #{attribute} applied to non string type" do
          expect { abstract_param_class.new(name, { type: 'string', attribute.to_sym => 2 }) }.
          to raise_error
        end
      end
    end

    it "should throw error if repeat is not 'true' or 'false'" do
      expect { abstract_param_class.new(name, { repeat: 111 }) }.to raise_error(Raml::AttributeMustBeTrueOrFalse)
    end

    it "should throw error if required is not 'true' or 'false'" do
      expect { abstract_param_class.new(name, { required: 111 }) }.to raise_error(Raml::AttributeMustBeTrueOrFalse)
    end
  end

  describe

end
