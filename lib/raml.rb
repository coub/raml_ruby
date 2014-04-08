require_relative 'raml/version'

require_relative 'raml/node'
require_relative 'raml/method'
require_relative 'raml/parser'
require_relative 'raml/resource'
require_relative 'raml/root'
require_relative 'raml/response'
require_relative 'raml/body'
require_relative 'raml/header'

require_relative 'raml/parameter/abstract_parameter'
require_relative 'raml/parameter/form_parameter'
require_relative 'raml/parameter/query_parameter'
require_relative 'raml/parameter/uri_parameter'

module Raml
  def self.load(raml)
    Raml::Parser.new(raml)
  end

  def self.load_file(filename)
    file = File.new(filename)
    Raml::Parser.new(file.read)
  end
end
