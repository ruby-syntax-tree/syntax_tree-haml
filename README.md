# SyntaxTree::Haml

[![Build Status](https://github.com/ruby-syntax-tree/syntax_tree-haml/actions/workflows/main.yml/badge.svg)](https://github.com/ruby-syntax-tree/syntax_tree-haml/actions/workflows/main.yml)
[![Gem Version](https://img.shields.io/gem/v/syntax_tree-haml.svg)](https://rubygems.org/gems/syntax_tree-haml)

[Syntax Tree](https://github.com/ruby-syntax-tree/syntax_tree) support for the [Haml template language](https://haml.info/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "syntax_tree-haml"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install syntax_tree-haml

## Usage

From code:

```ruby
require "syntax_tree/haml"

pp SyntaxTree::Haml.parse(source) # print out the AST
puts SyntaxTree::Haml.format(source) # format the AST
```

From the CLI:

```sh
$ stree ast --plugins=haml template.haml
(root children=[(tag name="span" value="Hello, world!")])
```

or

```sh
$ stree format --plugins=haml template.haml
%span Hello, world!
```

or

```sh
$ stree write --plugins=haml template.haml
template.haml 1ms
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests. You can also run `bundle console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruby-syntax-tree/syntax_tree-haml.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
