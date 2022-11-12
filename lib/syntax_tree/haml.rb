# frozen_string_literal: true

require "haml"
require "prettier_print"
require "syntax_tree"

module SyntaxTree
  module Haml
    DOCTYPE_TYPES = {
      "basic" => "Basic",
      "frameset" => "Frameset",
      "mobile" => "Mobile",
      "rdfa" => "RDFa",
      "strict" => "Strict",
      "xml" => "XML"
    }

    DOCTYPE_VERSIONS = %w[1.1 5]

    # This is the parent class of the various visitors that we provide to access
    # the HAML syntax tree.
    class Visitor
      def visit(node)
        node&.accept(self)
      end
    end

    # This is the main parser entrypoint, and just delegates to the Haml gem's
    # parser to do the heavy lifting.
    def self.parse(source)
      ::Haml::Parser.new({}).call(source)
    end

    # This is the main entrypoint for the formatter. It parses the source,
    # builds a formatter, then pretty prints the result.
    def self.format(source, maxwidth = 80, options: Formatter::Options.new)
      formatter = Format::Formatter.new(source, +"", maxwidth, options: options)
      parse(source).format(formatter)

      formatter.flush
      formatter.output
    end

    # This is a required API for syntax tree which just delegates to File.read.
    def self.read(filepath)
      File.read(filepath)
    end
  end

  # Register our module as a handler for the .haml file type.
  register_handler(".haml", Haml)
end

require "syntax_tree/haml/format"
require "syntax_tree/haml/pretty_print"

class Haml::Parser::ParseNode
  # Here we're going to hook into the parse node and define a method that will
  # accept a visitor in order to walk through the tree.
  def accept(visitor)
    case type
    when :comment
      visitor.visit_comment(self)
    when :doctype
      visitor.visit_doctype(self)
    when :filter
      visitor.visit_filter(self)
    when :haml_comment
      visitor.visit_haml_comment(self)
    when :plain
      visitor.visit_plain(self)
    when :root
      visitor.visit_root(self)
    when :script
      visitor.visit_script(self)
    when :silent_script
      visitor.visit_silent_script(self)
    when :tag
      visitor.visit_tag(self)
    else
      raise "Unknown node type: #{type}"
    end
  end

  def format(q)
    accept(SyntaxTree::Haml::Format.new(q))
  end

  def pretty_print(q)
    accept(SyntaxTree::Haml::PrettyPrint.new(q))
  end
end
