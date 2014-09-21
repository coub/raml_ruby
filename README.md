# RAML ruby

Implementation of a RAML parser in Ruby. It uses the stdlib YAML parser
(Psych). It can also generate HTML documentation.


<!---
## Installation

Add this line to your application's Gemfile:

    gem 'raml-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install raml-ruby
-->

## Usage

Clone this repository:

    git clone git@github.com:coub/raml_ruby.git

Require:

    require 'lib/raml'

or

    pry -r ./lib/raml.rb

To parse the file:

    Raml.pase_file("path/to/your/file.raml")

To generate HTML documentation:

    # write to file
    Raml.document("/path/to/your/file.raml", "path/to/output/file.html")

    # or just on screen
    Raml.document("/path/to/your/file.raml")

## To Do

- Align mergin strategy of conflicting properties of resource types and traits with official Javascript and Java parsers.
- Security schemes
- Publish to Rubygems

More a more detailed analysis of the spec requirements and which ones are finishes see the [RAML requirements document](raml_spec_reqs.md).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
