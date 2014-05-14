# Raml::Ruby

Simple gem to access RAML files using Ruby. It can also be used to generate documentation, although this part might be extracted in the future.

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

```
git clone git@github.com:coub/raml_ruby.git
```

Require:

```
require 'lib/raml'
```

or

```
pry -r ./lib/raml.rb
```

To parse the file:

```
Raml.load_file("path/to/your/file.raml").parse
```

To generate Markdown documentation:

```
# write to file
Raml.document("/path/to/your/file.raml", "path/to/output/file.md")

# or just on screen
Raml.document("/path/to/your/file.raml")
```

###To Do:
**Parser**

1. Named parameters with multiple types
2. Find the way to handle `!include` tag properly
3. Resource types
4. Resource traits
5. Security schemes
6. Publish to Rubygems

**Documentation**

1. General cleanup of everything

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
