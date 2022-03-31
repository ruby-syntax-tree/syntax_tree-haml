# frozen_string_literal: true

module SyntaxTree
  module Haml
    class Root
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        node.children.each do |child|
          child.format(q)
          q.breakable(force: true)
        end
      end

      def pretty_print(q)
        q.group(2, "(root", ")") do
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
