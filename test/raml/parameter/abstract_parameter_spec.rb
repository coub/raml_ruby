require_relative '../spec_helper'

describe Raml::Parameter::AbstractParameter do
  let(:abstract_param_class) { Raml::Parameter::AbstractParameter }
  let(:root_data) { {'title' => 'x', 'baseUri' => 'http://foo.com'} }
  let(:root) { Raml::Root.new root_data }
  subject { abstract_param_class.new(name, parameter_data, root) }

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

    context 'when example property is given' do
      context 'when the example property is a string' do
        let(:parameter_data) { { 'example' =>  'My Attribute' } }
        it { expect { subject }.to_not raise_error }
        it 'should store the value' do
          subject.example.should eq parameter_data['example']
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

  describe '#merge' do
    let(:other ) { Raml::Parameter::AbstractParameter.new 'name', other_data , root }
    let(:param) { Raml::Parameter::AbstractParameter.new 'name', param_data, root }
    subject(:merged_param) { param.merge other }

    context 'when trying to merge parameters of different names' do
      let(:other ) { Raml::Parameter::AbstractParameter.new 'name1', {}, root }
      let(:param) { Raml::Parameter::AbstractParameter.new 'name2', {}, root }
      it { expect { merged_param }.to raise_error Raml::MergeError }
    end
    context 'when a single type parameter is merged' do
      context 'with a single type parameter' do
        context 'when the parameter being merged into already has that property set' do
          context 'displayName property' do
            let(:other_data) { {displayName: 'other displayName' } }
            let(:param_data) { {displayName: 'param displayName'} }
            it 'overrides it' do
              merged_param.display_name.should eq 'other displayName'
            end
          end
          context 'description property' do
            let(:other_data) { {description: 'other description'     } }
            let(:param_data) { {description: 'param description'} }
            it 'overrides it' do
              merged_param.description.should eq 'other description'
            end
          end
          context 'type property' do
            let(:other_data) { {type: 'string' } }
            let(:param_data) { {type: 'number' } }
            it 'overrides it' do
              merged_param.type.should eq 'string'
            end
          end
          context 'enum property' do
            let(:other_data) { {enum: [ 'other'  ] } }
            let(:param_data) { {enum: [ 'param' ] } }
            it 'overrides it' do
              merged_param.enum.should eq [ 'other' ]
            end
          end
          context 'pattern property' do
            let(:other_data) { {pattern: 'other'     } }
            let(:param_data) { {pattern: 'param' } }
            it 'overrides it' do
              merged_param.pattern.should eq /other/
            end
          end
          context 'min_length property' do
            let(:other_data) { {min_length: 1 } }
            let(:param_data) { {min_length: 2 } }
            it 'overrides it' do
              merged_param.min_length.should eq 1
            end
          end
          context 'max_length property' do
            let(:other_data) { {max_length: 1 } }
            let(:param_data) { {max_length: 2 } }
            it 'overrides it' do
              merged_param.max_length.should eq 1
            end
          end
          context 'minimum property' do
            let(:other_data) { {type: 'number', minimum: 1 } }
            let(:param_data) { {type: 'number', minimum: 2 } }
            it 'overrides it' do
              merged_param.minimum.should eq 1
            end
          end
          context 'maximum property' do
            let(:other_data) { {type: 'number', maximum: 1 } }
            let(:param_data) { {type: 'number', maximum: 2 } }
            it 'overrides it' do
              merged_param.maximum.should eq 1
            end
          end
          context 'example property' do
            let(:other_data) { {example: 'other example'     } }
            let(:param_data) { {example: 'param example'} }
            it 'overrides it' do
              merged_param.example.should eq 'other example'
            end
          end
          context 'repeat property' do
            let(:other_data) { {repeat: true  } }
            let(:param_data) { {repeat: false } }
            it 'overrides it' do
              merged_param.repeat.should eq true
            end
          end
          context 'required property' do
            let(:other_data) { {required: true  } }
            let(:param_data) { {required: false } }
            it 'overrides it' do
              merged_param.required.should eq true
            end
          end
          context 'default property' do
            let(:other_data) { {default: 'other default'     } }
            let(:param_data) { {default: 'param default' } }
            it 'overrides it' do
              merged_param.default.should eq 'other default'
            end
          end
        end
        context 'when the parameter being merged into does not have that property set' do
          let(:param_data) { {} }
          context 'displayName property' do
            let(:other_data) { {displayName: 'other displayName'} }
            it 'can override it' do
              merged_param.display_name.should eq other.display_name
            end
          end
          context 'description property' do
            let(:other_data) { {description: 'other description'} }
            it 'can override it' do
              merged_param.description.should eq other.description
            end
          end
          context 'type property' do
            let(:other_data) { {type: 'string'} }
            it 'can override it' do
              merged_param.type.should eq other.type
            end
          end
          context 'enum property' do
            let(:other_data) { {enum: [ 'other' ]} }
            it 'can override it' do
              merged_param.enum.should eq other.enum
            end
          end
          context 'pattern property' do
            let(:other_data) { {pattern: 'other'} }
            it 'can override it' do
              merged_param.pattern.should eq other.pattern
            end
          end
          context 'min_length property' do
            let(:other_data) { {min_length: 1} }
            it 'can override it' do
              merged_param.min_length.should eq other.min_length
            end
          end
          context 'max_length property' do
            let(:other_data) { {max_length: 1} }
            it 'can override it' do
              merged_param.max_length.should eq other.max_length
            end
          end
          context 'minimum property' do
            let(:other_data) { {type: 'number', minimum: 1} }
            it 'can override it' do
              merged_param.minimum.should eq other.minimum
            end
          end
          context 'maximum property' do
            let(:other_data) { {type: 'number', maximum: 1} }
            it 'can override it' do
              merged_param.maximum.should eq other.maximum
            end
          end
          context 'example property' do
            let(:other_data) { {example: 'other example'} }
            it 'can override it' do
              merged_param.example.should eq other.example
            end
          end
          context 'repeat property' do
            let(:other_data) { {repeat: true} }
            it 'can override it' do
              merged_param.repeat.should eq other.repeat
            end
          end
          context 'required property' do
            let(:other_data) { {required: true} }
            it 'can override it' do
              merged_param.required.should eq other.required
            end
          end
          context 'default property' do
            let(:other_data) { {default: 'other default'} }
            it 'can override it' do
              merged_param.default.should eq other.default
            end
          end
        end
      end
      context 'with a multiple type parameter' do
        let(:param_data) { [
          { type: 'number' , description: 'param1' },
          { type: 'boolean', description: 'param2' },
        ] }
        context 'when none of the parameter types match the type of the merged parameter' do
          let(:other_data) { {type: 'string', description: 'other'} }
          it 'adds the new type as an option' do
            merged_param.types.keys.should contain_exactly('string', 'number', 'boolean')
          end
        end
        context 'when one of the parameter types matches the type of the merged parameter' do
          let(:other_data) { {type: 'number', description: 'other', minimum: 5} }
          it 'merges the matching types' do
            merged_param.types.keys.should contain_exactly('number', 'boolean')
            merged_param.types['number'].description.should eq other.description
            merged_param.types['number'].minimum.should eq other.minimum
          end
        end
      end
    end
    context 'when a multiple type parameter is merged' do
      let(:other_data) { [
        { type: 'number' , description: 'other1', minimum: 5 },
        { type: 'boolean', description: 'other2' },
      ] }
      context 'with a single type parameter' do
        context 'when the parameter type does not match any type of the merged parameter' do
          let(:param_data) { {type: 'string', description: 'param'} }
          it 'converts the parameter to multiple types' do
            merged_param.should be_has_multiple_types
          end
          it 'adds the other types as an alternative' do
            merged_param.types.keys.should contain_exactly('string', 'number', 'boolean')
          end
        end
        context 'when the parameter type matches one of the types of the merged parameter' do
          let(:param_data) { {type: 'number', description: 'param'} }
          it 'converts the parameter to multiple types' do
            merged_param.should be_has_multiple_types
          end
          it 'merges the overriding type with the matching other type' do
            merged_param.types.keys.should contain_exactly('number', 'boolean')
            merged_param.types['number'].description.should eq 'other1'
            merged_param.types['number'].minimum.should eq 5
          end
        end
      end
      context 'with a multiple type parameter' do
        let(:param_data) { [
          { type: 'number' , description: 'param1' },
          { type: 'string' , description: 'param2' },
        ] }
        it 'merges types that match and adds those that dont' do
            merged_param.types.keys.should contain_exactly('string', 'number', 'boolean')
            merged_param.types['number'].description.should eq 'other1'
            merged_param.types['number'].minimum.should eq 5
        end
      end
    end
  end

end
