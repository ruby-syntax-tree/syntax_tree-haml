# frozen_string_literal: true

require "haml"
require "prettier_print"
require "syntax_tree"

require "syntax_tree/haml/comment"
require "syntax_tree/haml/doctype"
require "syntax_tree/haml/filter"
require "syntax_tree/haml/haml_comment"
require "syntax_tree/haml/plain"
require "syntax_tree/haml/root"
require "syntax_tree/haml/script"
require "syntax_tree/haml/silent_script"
require "syntax_tree/haml/tag"

class Haml::Parser::ParseNode
  def format(q)
    syntax_tree.format(q)
  end

  def pretty_print(q)
    syntax_tree.pretty_print(q)
  end

  private

  def syntax_tree
    case type
    when :comment then SyntaxTree::Haml::Comment.new(self)
    when :doctype then SyntaxTree::Haml::Doctype.new(self)
    when :filter then SyntaxTree::Haml::Filter.new(self)
    when :haml_comment then SyntaxTree::Haml::HamlComment.new(self)
    when :plain then SyntaxTree::Haml::Plain.new(self)
    when :root then SyntaxTree::Haml::Root.new(self)
    when :script then SyntaxTree::Haml::Script.new(self)
    when :silent_script then SyntaxTree::Haml::SilentScript.new(self)
    when :tag then SyntaxTree::Haml::Tag.new(self)
    else
      raise ArgumentError, "Unsupported type: #{type}"
    end
  end
end

module SyntaxTree
  module Haml
    def self.parse(source)
      ::Haml::Parser.new({}).call(source)
    end

    def self.format(source, maxwidth = 80)
      PrettierPrint.format(+"", maxwidth) { |q| parse(source).format(q) }
    end

    def self.read(filepath)
      File.read(filepath)
    end

    def self.with_children(node, q)
      if node.children.empty?
        q.group { yield }
      else
        q.group do
          q.group { yield }
          q.indent do
            node.children.each do |child|
              q.breakable(force: true)
              child.format(q)
            end
          end
        end
      end
    end
  end

  # Register our module as a handler for the .haml file type.
  register_handler(".haml", Haml)
end
