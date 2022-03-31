# frozen_string_literal: true

module SyntaxTree
  module Haml
    # https://haml.info/docs/yardoc/file.REFERENCE.html#doctype-
    class Doctype
      TYPES = {
        "basic" => "Basic",
        "frameset" => "Frameset",
        "mobile" => "Mobile",
        "rdfa" => "RDFa",
        "strict" => "Strict",
        "xml" => "XML"
      }

      VERSIONS = ["1.1", "5"]

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        parts = ["!!!"]

        parts <<
          if TYPES.key?(node.value[:type])
            TYPES[node.value[:type]]
          elsif VERSIONS.include?(node.value[:version])
            node.value[:version]
          else
            node.value[:type]
          end

        parts << node.value[:encoding] if node.value[:encoding]
        q.text(parts.join(" "))
      end

      def pretty_print(q)
        q.group(2, "(doctype", ")") do
          q.breakable

          if TYPES.key?(node.value[:type])
            q.text("type=")
            q.pp(node.value[:type])
          elsif VERSIONS.include?(node.value[:version])
            q.text("version=")
            q.pp(node.value[:version])
          else
            q.text("type=")
            q.pp(node.value[:type])
          end

          if node.value[:encoding]
            q.breakable
            q.text("encoding=")
            q.pp(node.value[:encoding])
          end
        end
      end
    end
  end
end
