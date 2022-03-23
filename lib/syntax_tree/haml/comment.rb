# frozen_string_literal: true

class SyntaxTree < Ripper
  module Haml
    # https://haml.info/docs/yardoc/file.REFERENCE.html#html-comments-
    class Comment
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        Haml.with_children(node, q) do
          q.text("/")
          q.text("!") if node.value[:revealed]

          if node.value[:conditional]
            q.text(node.value[:conditional])
          elsif node.value[:text]
            q.text(" #{node.value[:text]}")
          end
        end
      end

      def pretty_print(q)
        q.group(2, "(comment", ")") do
          q.breakable

          if node.value[:conditional]
            q.text("conditional=")
            q.pp(node.value[:conditional])
          elsif node.value[:text]
            q.text("text=")
            q.pp(node.value[:text])
          end

          if node.value[:revealed]
            q.breakable
            q.text("revealed")
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
