require_relative 'raml/version'
require_relative 'raml/module'

require_relative 'raml/mixin/documentable'
require_relative 'raml/mixin/merge'
require_relative 'raml/mixin/parent'
require_relative 'raml/mixin/validation'

require_relative 'raml/parameter/abstract_parameter'
require_relative 'raml/parameter/form_parameter'
require_relative 'raml/parameter/query_parameter'
require_relative 'raml/parameter/uri_parameter'
require_relative 'raml/parameter/base_uri_parameter'

require_relative 'raml/schema'
require_relative 'raml/schema_reference'

require_relative 'raml/header'
require_relative 'raml/body'
require_relative 'raml/response'

require_relative 'raml/abstract_method'
require_relative 'raml/trait_reference'
require_relative 'raml/trait'
require_relative 'raml/method'
require_relative 'raml/abstract_resource'

require_relative 'raml/parser'
require_relative 'raml/resource_type_reference'
require_relative 'raml/resource_type'
require_relative 'raml/resource'
require_relative 'raml/documentation'
require_relative 'raml/exceptions'
require_relative 'raml/include'
require_relative 'raml/root'

module Raml
  def self.load(raml)
    Raml::Parser.new(raml)
  end

  def self.load_file(filename)
    file = File.new(filename)
    raise UnsupportedRamlVersion unless file.readline =~ /\A#%RAML 0.8\s*\z/
    
    path = File.dirname filename
    path = nil if path == ''
    
    Raml::Parser.new(file.read, path)
  end

  def self.document(filepath, out_file = nil)
    parser = load_file(filepath)
    documentation = parser.parse.document

    if out_file
      File.open(out_file, 'w') do |f|
        f.write documentation
      end
    else
      documentation
    end
  end

  # Transforms camel cased identificators to underscored.
  def self.underscore(camel_cased_word)
    camel_cased_word.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  def self.camel_case(underscored_word)
    w = underscored_word.to_s.split('_')
    (w[0...1] + w[1..-1].map(&:capitalize)).join
  end

  def self.code_indenter(code)
    code.split("\n").map{|line| ' ' * 4 + line}.join("\n")
  end

  def self.nbsp_indenter(text, indent_depth = 4)
    text.split("\n").map{|line| '&nbsp;' * indent_depth + line}.join("\n")
  end
end
