# frozen_string_literal: true

require "ripper"
require_relative "lib/syntax_tree/haml/version"

Gem::Specification.new do |spec|
  spec.name = "syntax_tree-haml"
  spec.version = SyntaxTree::Haml::VERSION
  spec.authors = ["Kevin Newton"]
  spec.email = ["kddnewton@gmail.com"]

  spec.summary = "Syntax Tree support for Haml"
  spec.homepage = "https://github.com/ruby-syntax-tree/syntax_tree-haml"
  spec.license = "MIT"
  spec.metadata = { "rubygems_mfa_required" => "true" }

  spec.files =
    Dir.chdir(__dir__) do
      `git ls-files -z`.split("\x0")
        .reject { |f| f.match(%r{^(test|spec|features)/}) }
    end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency "haml", ">= 5.2"
  spec.add_dependency "prettier_print", ">= 1.2.1"
  spec.add_dependency "syntax_tree", ">= 6.0.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
end
