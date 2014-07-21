require_relative 'raml/version'

require_relative 'raml/common'

require_relative 'raml/parameter/abstract_parameter'

require_relative 'raml/protocol'
require_relative 'raml/method'
require_relative 'raml/parser'
require_relative 'raml/resource'
require_relative 'raml/root'
require_relative 'raml/response'
require_relative 'raml/body'
require_relative 'raml/header'
require_relative 'raml/documentation'
require_relative 'raml/exceptions'
require_relative 'raml/include'


require_relative 'raml/parameter/form_parameter'
require_relative 'raml/parameter/query_parameter'
require_relative 'raml/parameter/uri_parameter'

module Raml
  def self.load(raml)
    Raml::Parser.new(raml)
  end

  def self.load_file(filename)
    file = File.new(filename)
    path = File.dirname filename
    path = nil if path == ''
    Raml::Parser.new(file.read, path)
  end

  def self.document(filepath, out_file = nil)
    parser = load_file(filepath)
    documentation = parser.parse.document

    if out_file
      file = File.open(out_file, 'w') do |f|
        f.write(documentation)
      end
    else
      documentation
    end
  end
end
