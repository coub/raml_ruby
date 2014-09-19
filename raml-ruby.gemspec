# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'raml/version'

Gem::Specification.new do |spec|
  spec.name          = "raml-ruby"
  spec.version       = Raml::VERSION
  spec.authors       = ["kgorin"]
  spec.email         = ["me@kgor.in"]
  spec.description   = %q{RAML parser.}
  spec.summary       = %q{RAML parser.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '~> 4.1'
  spec.add_dependency 'json-schema'  , '~> 2.2'
  spec.add_dependency 'kramdown'     , '~> 1.4'
  spec.add_dependency 'rouge'        , '~> 1.7'  
  spec.add_dependency 'sass'         , '~> 3.4'
  spec.add_dependency 'slim'         , '~> 2.0'
  spec.add_dependency 'uri_template' , '~> 0.7'

  spec.add_development_dependency 'bundler', "~> 1.3"
  spec.add_development_dependency 'rake'   , '~> 10.0'
  spec.add_development_dependency 'rspec'  , '~> 3.0'
  spec.add_development_dependency 'rr'     , '~> 1.1' 
  spec.add_development_dependency "pry"    , '~> 0.10'
end
