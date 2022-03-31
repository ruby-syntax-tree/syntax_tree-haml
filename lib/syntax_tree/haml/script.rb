# frozen_string_literal: true

module SyntaxTree
  module Haml
    # https://haml.info/docs/yardoc/file.REFERENCE.html#inserting_ruby
    class Script
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        Haml.with_children(node, q) do
          q.text("&") if node.value[:escape_html]

          if node.value[:preserve]
            q.text("~")
          else
            q.text("=")
          end

          q.text(" ")
          q.text(node.value[:text].strip)
        end
      end

      def pretty_print(q)
        q.group(2, "(script", ")") do
          q.breakable
          q.text("text=")
          q.pp(node.value[:text])

          if node.value[:escape_html]
            q.breakable
            q.text("escape_html")
          end

          if node.value[:preserve]
            q.breakable
            q.text("preserve")
          end

          if node.children.any?
            q.breakable
            q.text("children=")
            q.pp(node.children)
          end
        end
      end
    end
  end
end
