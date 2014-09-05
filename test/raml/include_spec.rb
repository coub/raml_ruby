require_relative 'spec_helper'
require 'ostruct'

describe Raml::Parser::Include do
  let(:include) { Raml::Parser::Include.new }
  describe '#init_with' do
    it 'fetches the path from the given Psych::Coder instance' do
      include.init_with OpenStruct.new scalar: 'path_to_file'
      include.path.should eq 'path_to_file'
    end
  end
  
  describe '#content' do
    before { include.init_with OpenStruct.new scalar: path }
    context 'when the path in the include directive is absolute' do
      let(:path) { '/absolute_file_path'}
      it 'opens and reads the file' do
        mock(File).open(path).stub!.read { 'content' }
        include.content('cwd').should eq 'content'
      end
    end
    context 'when the path in the include directive is relative' do
      let(:path) { 'relative_file_path'}
      it 'opens and reads the file' do
        mock(File).open("cwd/#{path}").stub!.read { 'content' }
        include.content('cwd').should eq 'content'
      end
    end
    [ 'yaml', 'yml', 'raml' ].each do |ext|
      context "when include directive points to a file ending in .#{ext}" do
        let(:path) { "/absolute_file_path.#{ext}" }
        let(:content) { { 'a' => [1,2,3], 'b' => 4 } }
        it 'parses the file as YAML' do
          stub(File).open(path).stub!.read { content.to_yaml }
          include.content('cwd').should eq content
        end
      end
    end
  end
end