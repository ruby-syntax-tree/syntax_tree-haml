# frozen_string_literal: true

class SyntaxTree < Ripper
  module Haml
    # https://haml.info/docs/yardoc/file.REFERENCE.html#filters
    class Filter
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
        q.group do
          q.text(":")
          q.text(node.value[:name])

          q.indent do
            q.breakable(force: true)

            segments = node.value[:text].strip.split("\n")
            q.seplist(segments, -> { q.breakable(force: true) }) do |segment|
              q.text(segment)
            end
          end
        end
      end

      def pretty_print(q)
        q.group(2, "(filter", ")") do
          q.breakable
          q.text("name=")
          q.text(node.value[:name])

          q.breakable
          q.text("text=")
          q.pp(node.value[:text])
        end
      end
    end
  end
end
