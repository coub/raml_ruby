require_relative 'spec_helper'

describe Raml::Template do
  let(:root) { Raml::Root.new 'title' => 'x', 'baseUri' => 'http://foo.com' }

	describe '#new' do
	end

	describe '#interpolate' do
		subject { Raml::Template.new('foo', data, root).interpolate params }
		context 'when the data requires no parameters' do
			let(:params) { {} }
			context 'when its a shallow object' do
				let(:data  ) { {'aaa' => 'bbb', 'ccc' => 'ddd', 'eee' => 'fff' } }
				it 'returns the same data that was inputted' do
					subject[1].should eq data
				end
			end
			context 'when its a nested object' do
			let(:data  ) { {'aaa' => 'bbb', 'ccc' => [ 'ddd', 'eee' ], 'fff' => { 'ggg' => 'hhh', 'iii' => ['jjj'] } } }
				it 'returns the same data that was inputted' do
					subject[1].should eq data
				end
			end
		end
		context 'when the data requires parameters' do
			context 'when its a shallow object' do
				let(:data  ) { {'aaa <<foo>>' => 'bbb', 'ccc' => '<<bar>> ddd', 'eee' => 'fff' } }
				context 'when a required parameter is missing' do
					let(:params) { { 'foo' => 'bar' } }
					it do
						expect { subject }.to raise_exception Raml::UnknownTypeOrTraitParameter
					end
				end
				context 'when all parameters are given' do
					let(:params) { { 'foo' => 'bar', 'bar' => 'baz' } }
					it 'returns the name with the parameter interpolated' do
						subject[1].should eq ({'aaa bar' => 'bbb', 'ccc' => 'baz ddd', 'eee' => 'fff' })
					end
				end
			end
			context 'when its a nested object' do
			let(:data  ) { {'aaa <<foo>>' => 'bbb', 'ccc' => [ '<<bar>> ddd', 'eee' ], 'fff' => { 'ggg' => 'hhh', '<<baz>> iii' => ['<<jaz>> jjj'] } } }
				context 'when a required parameter is missing' do
					let(:params) { { 'foo' => 'bar' } }
					it do
						expect { subject }.to raise_exception Raml::UnknownTypeOrTraitParameter
					end
				end
				context 'when all parameters are given' do
					let(:params) { { 'foo' => 'bar', 'bar' => 'baz', 'baz' => 'jaz', 'jaz' => 'max' } }
					it 'returns the name with the parameter interpolated' do
						subject[1].should eq ({'aaa bar' => 'bbb', 'ccc' => [ 'baz ddd', 'eee' ], 'fff' => { 'ggg' => 'hhh', 'jaz iii' => ['max jjj'] } })
					end
				end
			end
		end
		context 'when function parameters are used' do
			context 'when the function is not known' do
				let(:params) { {'some_param' => 'test'} }
				let(:data  ) { {'bar' => '<<some_param | !unknown>>'} }
				it do
					expect { subject }.to raise_exception Raml::UnknownTypeOrTraitParamFunction
				end
			end
			context 'when the function is singularize' do
				let(:data) { {'bar' => 'some <<some_param | !singularize>>'} }
				context 'when the parameter is plural' do
					let(:params) { {'some_param' => 'tests'} }
					it 'signularizes it' do
						subject[1]['bar'].should eq  'some test'
					end
				end
				context 'when the parameter is singular' do
					let(:params) { {'some_param' => 'test'} }
					it 'keeps it singular' do
						subject[1]['bar'].should eq  'some test'
					end
				end
			end
			context 'when the function is pluralize' do
				let(:data) { {'bar' => 'some <<some_param | !pluralize>>'} }
				context 'when the parameter is singular' do
					let(:params) { {'some_param' => 'test'} }
					it 'pluralizes it' do
						subject[1]['bar'].should eq  'some tests'
					end
				end
				context 'when the parameter is plural' do
					let(:params) { {'some_param' => 'tests'} }
					it 'keeps it plural' do
						subject[1]['bar'].should eq  'some tests'
					end
				end
			end
		end
	end
end