require_relative '../spec_helper'

describe Raml::Parameter::AbstractParameter do
  describe '#new' do
    let(:abstract_param_class) { Raml::Parameter::AbstractParameter }

    it 'should initialize ' do
      param_data = {
        type: 'integer',
        required: true,
        example: 253995,
        minimum: 33
      }

      param = abstract_param_class.new(param_data)
    end

    it 'should default parameter type to string' do
      param = abstract_param_class.new({ required: true })
      param.type.should == 'string'
    end

    describe 'valid parameter types' do
      Raml::Parameter::AbstractParameter::VALID_TYPES.each do |type|
        it "should allow type #{type}" do
          param = abstract_param_class.new({ type: type })
          param.type.should == type
        end
      end

      it 'should throw error if type is invalid' do
        invalid_type = 'unicorn'
        expect { abstract_param_class.new({ type: invalid_type }) }.
        to raise_error
      end
    end

    describe "minLength / maxLength" do
      it 'should throw warning if minLength applied to non string type' do
        expect { abstract_param_class.new({ type: 'integer', min_length: 2 }) }.
        to raise_error
      end

      it 'should throw warning if maxLength applied to non string type' do
        expect { abstract_param_class.new({ type: 'integer', max_length: 2 }) }.
        to raise_error
      end
    end

    describe 'minimum / maximum' do
      %w(minimum maximum).each do |attribute|
        it "should throw warning if #{attribute} applied to non string type" do
          expect { abstract_param_class.new({ type: 'string', attribute.to_sym => 2 }) }.
          to raise_error
        end
      end
    end


  end

end
