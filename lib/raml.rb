require_relative 'raml/version'

require_relative 'raml/patch/module'
require_relative 'raml/patch/hash'

require_relative 'raml/exceptions'

require_relative 'raml/parser'
require_relative 'raml/parser/include'

require_relative 'raml/mixin/bodies'
require_relative 'raml/mixin/documentable'
require_relative 'raml/mixin/global'
require_relative 'raml/mixin/headers'
require_relative 'raml/mixin/merge'
require_relative 'raml/mixin/parent'
require_relative 'raml/mixin/validation'

require_relative 'raml/node'
require_relative 'raml/node/reference'
require_relative 'raml/node/parametized_reference'

require_relative 'raml/node/parameter/abstract_parameter'
require_relative 'raml/node/parameter/form_parameter'
require_relative 'raml/node/parameter/query_parameter'
require_relative 'raml/node/parameter/uri_parameter'
require_relative 'raml/node/parameter/base_uri_parameter'

require_relative 'raml/node/schema'
require_relative 'raml/node/schema_reference'

require_relative 'raml/node/header'
require_relative 'raml/node/body'
require_relative 'raml/node/response'

require_relative 'raml/node/trait_reference'
require_relative 'raml/node/resource_type_reference'

require_relative 'raml/node/template'

require_relative 'raml/node/abstract_method'
require_relative 'raml/node/trait'
require_relative 'raml/node/method'

require_relative 'raml/node/abstract_resource'
require_relative 'raml/node/resource_type'
require_relative 'raml/node/resource'
require_relative 'raml/node/abstract_resource_circular'

require_relative 'raml/node/documentation'

require_relative 'raml/node/root'

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

  def self.highlight(source, mimetype=nil)
    opts = { source: source }
    opts[:mimetype] = mimetype if mimetype
    
    formatter = Rouge::Formatters::HTML.new(css_class: 'highlight')
    lexer = Rouge::Lexer.guess(opts).new
    formatter.format lexer.lex source
  end
end
