# frozen_string_literal: true

class SyntaxTree < Ripper
  module Haml
    # https://haml.info/docs/yardoc/file.REFERENCE.html#haml-comments--
    class HamlComment
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        q.text("-#")
        text = node.value[:text].strip

        if text.include?("\n")
          q.indent do
            q.breakable(force: true)
            q.seplist(text.split("\n"), -> { q.breakable(force: true) }) do |segment|
              q.text(segment)
            end
          end
        else
          q.text(" #{text}")
        end
      end

      def pretty_print(q)
        q.group(2, "(haml_comment", ")") do
          q.breakable
          q.text("text=")
          q.pp(node.value[:text])
        end
      end
    end
  end
end
