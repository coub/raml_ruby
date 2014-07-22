require_relative '../spec_helper'

describe Raml::Parameter::AbstractParameter do
  describe '#new' do
    let(:abstract_param_class) { Raml::Parameter::AbstractParameter }
    let(:name) { 'page_number' }
    let(:parameter_data) {
      {
        type:     'integer',
        required: true,
        example:  253995,
        minimum:  33
      }
    }

    subject { abstract_param_class.new(name, parameter_data) }

    it 'should initialize ' do
      subject.name.should == name
    end

    context 'when a paratemer type is not supplied' do
      let(:parameter_data) { { required: true } }
      it 'should default parameter type to string' do
        subject.type.should == 'string'
      end
    end

    describe "Named Parameters With Multiple Types" do
      let(:parameter_data) {
        YAML.load %q(
          - type: string
            description: Text content. The text content must be the last field in the form.
          - type: file
            description: File to upload. The file must be the last field in the form.
        )
      }

      let(:name) { 'file' }

      subject { Raml::Parameter::UriParameter.new(name, parameter_data) }

      it "creates children for multiple types" do
        subject.children.should_not be_empty
      end

      it "prints out documentation" do
        subject.document
      end
    end


    context 'when the parameter type is valid' do
      %w(string number integer date boolean file).each do |type|
        context "when the parameter type is #{type}" do
          let(:parameter_data) { { type: type } }
          it { expect { subject }.to_not raise_error }
          it "allows the type" do
            subject.type.should == type
          end
        end
      end
    end
    context 'when the parameter type is invalid' do
      let(:parameter_data) { { type: 'invalid' } }
      it { expect { subject }.to raise_error Raml::InvalidParameterType }
    end

    context 'when the parameter type is string' do
      context 'and a minLength attribute is given' do
        let(:parameter_data) { { type: 'string', min_length: 2 } }
        it { expect { subject }.to_not raise_error }
        it "stores the attribute" do
          subject.min_length.should == 2
        end
      end
      context 'and a maxLength attribute is given' do
        let(:parameter_data) { { type: 'string', max_length: 2 } }
        it { expect { subject }.to_not raise_error }
        it "stores the attribute" do
          subject.max_length.should == 2
        end
      end
      context 'and an enum attribute is given' do
        context 'and the value is an array of strings' do
          let(:enum) { ['foo', 'bar'] }
          let(:parameter_data) { { type: 'string', enum: enum } }
          it { expect { subject }.to_not raise_error }
          it "stores the attribute" do
            subject.enum.should == enum
          end
        end
        context 'and the value is not an array' do
          let(:enum) { 'foo' }
          let(:parameter_data) { { type: 'string', enum: enum } }
          it { expect { subject }.to raise_error Raml::InvalidParameterAttribute }
        end
        context 'and the value is an array but not all elements are string' do
          let(:enum) { ['foo', 'bar', 2] }
          let(:parameter_data) { { type: 'string', enum: enum } }
          it { expect { subject }.to raise_error Raml::InvalidParameterAttribute }
        end
      end    
    end
    context 'when the parameter type is not string' do
      context 'and a minLength attribute is given' do
        let(:parameter_data) { { type: 'integer', min_length: 2 } }
        it { expect { subject }.to raise_error Raml::InapplicableParameterAttribute }
      end
      context 'and a maxLength attribute is given' do
        let(:parameter_data) { { type: 'integer', max_length: 2 } }
        it { expect { subject }.to raise_error Raml::InapplicableParameterAttribute }
      end
      context 'and an enum attribute is given' do
        let(:enum) { ['foo', 'bar'] }
        let(:parameter_data) { { type: 'integer', enum: enum } }
        it { expect { subject }.to raise_error Raml::InapplicableParameterAttribute }
      end
    end

    %w(integer number).each do |type|
      context "when the parameter type is #{type}" do
        context 'and a minimum attribute is given' do
          let(:parameter_data) { { type: type, minimum: 2 } }
          it { expect { subject }.to_not raise_error }
          it "stores the attribute" do
            subject.minimum.should == 2
          end
        end
        context 'and a maximum attribute is given' do
          let(:parameter_data) { { type: type, maximum: 2 } }
          it { expect { subject }.to_not raise_error }
          it "stores the attribute" do
            subject.maximum.should == 2
          end
        end
      end
    end
    context 'when the parameter type is not integer or number' do
      context 'and a minimum attribute is given' do
        let(:parameter_data) { { type: 'string', minimum: 2 } }
        it { expect { subject }.to raise_error Raml::InapplicableParameterAttribute }
      end
      context 'and a maximum attribute is given' do
        let(:parameter_data) { { type: 'string', maximum: 2 } }
        it { expect { subject }.to raise_error Raml::InapplicableParameterAttribute }
      end
    end

    %w{repeat required}.each do |attribute|
      context "when the #{attribute} attribute is not true or false" do
        let(:parameter_data) { { attribute => 111 } }
        it { expect { subject }.to raise_error Raml::InvalidParameterAttribute }
      end
      [ true, false ].each do |val|
        context "when the #{attribute} attribute is #{val}" do
          let(:parameter_data) { { attribute => val} }
          it { expect { subject }.to_not raise_error }
          it "stores the attribute" do
            subject.send(attribute.to_sym).should == val
          end
        end
      end
    end
  end
end
