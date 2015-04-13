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
  # Parses RAML from a string.
  #
  # @param raml [String] the string containing RAML.
  # @return [Raml::Root] the RAML root node.
  # @raise [RamlError] if the RAML is invalid.
  def self.parse(raml)
    Raml::Parser.parse raml
  end

  # Parses RAML from a file.
  #
  # @param filepath [String] the file path of the file containing RAML.
  # @return [Raml::Root] the RAML root node.
  # @raise [Errno::ENOENT] if the file can't be found.
  # @raise [Errno::EACCES] if the file can't be read.
  # @raise [RamlError] if the RAML is invalid.
  def self.parse_file(filepath)
    file = File.new filepath
    raise UnsupportedRamlVersion unless file.readline =~ /\A#%RAML 0.8\s*\z/

    path = File.dirname filepath
    path = nil if path == ''

    Raml::Parser.parse file.read, path
  end
end
