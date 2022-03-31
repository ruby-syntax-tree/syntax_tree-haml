# frozen_string_literal: true

module SyntaxTree
  module Haml
    # https://haml.info/docs/yardoc/file.REFERENCE.html#plain-text
    class Plain
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        text = node.value[:text]

        q.text("\\") if escaped?(text)
        q.text(text)
      end

      def pretty_print(q)
        q.group(2, "(plain", ")") do
          q.breakable
          q.text("text=")
          q.pp(node.value[:text])
        end
      end

      private

      # If a node comes in as the plain type but starts with one of the special
      # characters that haml parses, then we need to escape it with a \ when
      # printing.
      def escaped?(text)
        ::Haml::Parser::SPECIAL_CHARACTERS.any? do |special|
          text.start_with?(special)
        end
      end
    end
  end
end
