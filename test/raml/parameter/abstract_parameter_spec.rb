require_relative '../spec_helper'

describe Raml::Parameter::AbstractParameter do
  let(:abstract_param_class) { Raml::Parameter::AbstractParameter }
  subject { abstract_param_class.new(name, parameter_data) }
  
  describe '#new' do
    let(:name) { 'page_number' }
    let(:parameter_data) {
      {
        type:     'integer',
        required: true,
        example:  253995,
        minimum:  33
      }
    }

    it 'should initialize ' do
      subject.name.should == name
    end

    context 'when a paratemer type is not supplied' do
      let(:parameter_data) { { required: true } }
      it 'should default parameter type to string' do
        subject.type.should == 'string'
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
        context 'and the value is an integer' do
          let(:parameter_data) { { type: 'string', min_length: 2 } }
          it { expect { subject }.to_not raise_error }
          it "stores the attribute" do
            subject.min_length.should == 2
          end
        end
        context 'and the value is not an integer' do
          let(:parameter_data) { { type: 'string', min_length: 2.0 } }
          it { expect { subject }.to raise_error Raml::InvalidParameterAttribute }
        end
      end
      context 'and a maxLength attribute is given' do
        context 'and the value is an integer' do
          let(:parameter_data) { { type: 'string', max_length: 2 } }
          it { expect { subject }.to_not raise_error }
          it "stores the attribute" do
            subject.max_length.should == 2
          end
        end
        context 'and the value is not an integer' do
          let(:parameter_data) { { type: 'string', max_length: 2.0 } }
          it { expect { subject }.to raise_error Raml::InvalidParameterAttribute }
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
      context 'and an pattern attribute is given' do
        let(:parameter_data) { { type: 'string', pattern: pattern } }
        context 'and the value is string representing a valid regexp' do
          let(:pattern) { '[a-z]*' }
          it { expect { subject }.to_not raise_error }
          it 'it converts the attribute into a Regexp object' do
            subject.pattern.should == /[a-z]*/
          end
          context 'when the regexp has JS ^ anchors' do
            let(:pattern) { "^[a-z]*\\\\^" }
            it 'replaces them with the Ruby \\A anchor' do
              subject.pattern.should == /\A[a-z]*\\\A/
            end
          end
          context 'when the regexp has JS $ anchors' do
            let(:pattern) { '$[a-z]*\\\\$' }
            it 'replaces them with the Ruby \\z anchor' do
              subject.pattern.should == /\z[a-z]*\\\z/
            end
          end
          context 'when the regexp has escaped an escaped ^' do
            let(:pattern) { "\\^[a-z]*\\\\\\^" }
            it 'doesnt replace them' do
              subject.pattern.should == /\^[a-z]*\\\^/
            end
          end
          context 'when the regexp has escaped an escaped $' do
            let(:pattern) { "\\$[a-z]*\\\\\\$" }
            it 'doesnt replace them' do
              subject.pattern.should == /\$[a-z]*\\\$/
            end
          end
        end
        context 'and the pattern is not a string' do
          let(:pattern) { 1 }
          it { expect { subject }.to raise_error Raml::InvalidParameterAttribute }
        end
        context 'and the pattern an invalid regexp pattern' do
          let(:pattern) { '[' }
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
      context 'and a pattern attribute is given' do
        let(:parameter_data) { { type: 'integer', pattern: '[a-Z]*' } }
        it { expect { subject }.to raise_error Raml::InapplicableParameterAttribute }
      end
    end

    %w(integer number).each do |type|
      context "when the parameter type is #{type}" do
        %w(minimum maximum).each do |attribute|
          context "and a #{attribute} attribute is given" do
            context 'and the attribute\'s value is an integer' do
              let(:parameter_data) { { type: type, attribute => 2 } }
              it { expect { subject }.to_not raise_error }
              it "stores the attribute" do
                subject.send(attribute.to_sym).should == 2
              end
            end
            context 'and the attribute\'s value is an float' do
              let(:parameter_data) { { type: type, attribute => 2.1 } }
              it { expect { subject }.to_not raise_error }
              it "stores the attribute" do
                subject.send(attribute.to_sym).should == 2.1
              end
            end
            context 'and the attribute\'s value is not an integer or a float' do
              let(:parameter_data) { { type: type, attribute => '2' } }
              it { expect { subject }.to raise_error Raml::InvalidParameterAttribute }
            end
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
    
    [
      [ 'string' , 'string' , '123',  123  ],
      [ 'number' , 'number' ,  12.3, '123' ],
      [ 'integer', 'integer',  123 ,  12.3 ],
      [ 'date'   , 'string' , '123',  123  ],
      [ 'boolean', 'boolean',  true,  123  ]
    ].each do |test|
      param_type, attr_type, good_value, bad_value = test
      context "when the paramater type is a #{param_type}" do
        [ :example, :default ].each do |attr|
          context "when the #{attr} attribute is a #{attr_type}" do
            let(:parameter_data) { { type: param_type, attr => good_value } }
            it { expect { subject }.to_not raise_error }
            it "stores the attribute" do
              subject.send(attr).should == good_value
            end
          end
          context "when the #{attr} attribute is not a #{attr_type}" do
            let(:parameter_data) { { type: param_type, attr => bad_value } }
            it { expect { subject }.to raise_error Raml::InvalidParameterAttribute }
          end
        end
      end
    end
    
    %w{repeat required}.each do |attribute|
      context "when the #{attribute} attribute is not true or false" do
        let(:parameter_data) { { attribute => 111 } }
        it { expect { subject }.to raise_error Raml::InvalidParameterAttribute }
      end
      context "when the #{attribute} attribute is not given" do
        let(:parameter_data) { { } }
        it 'defaults to false' do
          subject.send(attribute.to_sym).should == false
        end
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
    
    context 'when the parameter has multiple types' do
      let(:parameter_data) {
        YAML.load %q(
          - type: string
            description: Text content. The text content must be the last field in the form.
          - type: file
            description: File to upload. The file must be the last field in the form.
        )
      }
      let(:name) { 'file' }

      it "creates children for multiple types" do
        subject.children.should_not be_empty
        subject.children.should all( be_a Raml::Parameter::AbstractParameter )
        subject.children.map(&:type).should contain_exactly 'string', 'file'
      end

      it "prints out documentation" do
        subject.document
      end
    end
  end
  
  describe '#has_multiple_types?' do
    let(:name) { 'file' }
    context 'when the parameter has a single type' do
      let(:parameter_data) { { type: 'string' } }
      it { subject.has_multiple_types?.should be false }
    end
    context 'when the parameter has multiple types' do
      let(:parameter_data) {
        YAML.load %q(
          - type: string
            description: Text content. The text content must be the last field in the form.
          - type: file
            description: File to upload. The file must be the last field in the form.
        )
      }
      
      it { subject.has_multiple_types?.should be true }
    end    
  end
end
