# RAML ruby

Implementation of a RAML parser in Ruby (uses Psych YAML parser). It
can also generate documentation, although this part might be extracted in the future.


<!---
## Installation

Add this line to your application's Gemfile:

    gem 'raml-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install raml-ruby
-->

## Warning

This project is at very early stage, some parts might be missing or not working. Todo list is located below, if you want to contribute you can find me on [RAML forums](http://forums.raml.org/t/ruby-rails-tooling/49) or just follow contribution guidelines.

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

- Find the way to handle `!include` tag properly
- Resource types
- Resource traits
- Security schemes
- Publish to Rubygems

**Documentation**

- Cleaner layouts

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
