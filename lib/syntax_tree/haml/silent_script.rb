# frozen_string_literal: true

module SyntaxTree
  module Haml
    # https://haml.info/docs/yardoc/file.REFERENCE.html#running-ruby--
    class SilentScript
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        q.group do
          q.text("- ")
          q.text(node.value[:text].strip)

          node.children.each do |child|
            if continuation?(child)
              q.breakable(force: true)
              child.format(q)
            else
              q.indent do
                q.breakable(force: true)
                child.format(q)
              end
            end
          end
        end
      end

      def pretty_print(q)
        q.group(2, "(silent_script", ")") do
          q.breakable
          q.text("text=")
          q.pp(node.value[:text])

          if node.children.any?
            q.breakable
            q.text("children=")
            q.pp(node.children)
          end
        end
      end

      private

      def continuation?(child)
        return false if child.type != :silent_script

        [node.value[:keyword], child.value[:keyword]] in
          ["case", "in" | "when" | "else"] |
          ["if" | "unless", "elsif" | "else"]
      end
    end
  end
end
