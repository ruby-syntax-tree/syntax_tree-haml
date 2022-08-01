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
    def self.format(source, maxwidth = 80)
      formatter = Format::Formatter.new(source, +"", maxwidth)
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
    in :comment
      visitor.visit_comment(self)
    in :doctype
      visitor.visit_doctype(self)
    in :filter
      visitor.visit_filter(self)
    in :haml_comment
      visitor.visit_haml_comment(self)
    in :plain
      visitor.visit_plain(self)
    in :root
      visitor.visit_root(self)
    in :script
      visitor.visit_script(self)
    in :silent_script
      visitor.visit_silent_script(self)
    in :tag
      visitor.visit_tag(self)
    end
  end

  def format(q)
    accept(SyntaxTree::Haml::Format.new(q))
  end

  def pretty_print(q)
    accept(SyntaxTree::Haml::PrettyPrint.new(q))
  end
end
