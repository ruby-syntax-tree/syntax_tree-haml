# frozen_string_literal: true

module SyntaxTree
  module Haml
    class PrettyPrint < Visitor
      attr_reader :q

      def initialize(q)
        @q = q
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#html-comments-
      def visit_comment(node)
        group("comment") do
          if node.value[:conditional]
            pp_field("conditional", node.value[:conditional])
          elsif node.value[:text]
            pp_field("text", node.value[:text])
          end

          bool_field("revealed") if node.value[:revealed]
          pp_field("children", node.children) if node.children.any?
        end
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#doctype-
      def visit_doctype(node)
        group("doctype") do
          if DOCTYPE_TYPES.key?(node.value[:type])
            pp_field("type", node.value[:type])
          elsif DOCTYPE_VERSIONS.include?(node.value[:version])
            pp_field("version", node.value[:version])
          else
            pp_field("text", node.value[:text])
          end

          pp_field("encoding", node.value[:encoding]) if node.value[:encoding]
        end
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#filter
      def visit_filter(node)
        group("filter") do
          text_field("name", node.value[:name])
          pp_field("text", node.value[:text])
        end
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#haml-comments--
      def visit_haml_comment(node)
        group("haml_comment") { pp_field("text", node.value[:text]) }
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#plain-text
      def visit_plain(node)
        group("plain") { pp_field("text", node.value[:text]) }
      end

      # Visit the root node of the AST.
      def visit_root(node)
        group("root") do
          pp_field("children", node.children) if node.children.any?
        end
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#inserting_ruby
      def visit_script(node)
        group("script") do
          pp_field("text", node.value[:text])
          bool_field("escape_html") if node.value[:escape_html]
          bool_field("preserve") if node.value[:preserve]
          pp_field("children", node.children) if node.children.any?
        end
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#running-ruby--
      def visit_silent_script(node)
        group("silent-script") do
          pp_field("text", node.value[:text])
          pp_field("children", node.children) if node.children.any?
        end
      end

      # Visit a tag node.
      def visit_tag(node)
        group("tag") do
          pp_field("name", node.value[:name])

          if node.value[:attributes].any?
            pp_field("attributes", node.value[:attributes])
          end

          if node.value[:dynamic_attributes].new
            pp_field(
              "dynamic_attributes.new",
              node.value[:dynamic_attributes].new
            )
          end

          if node.value[:dynamic_attributes].old
            pp_field(
              "dynamic_attributes.old",
              node.value[:dynamic_attributes].old
            )
          end

          if node.value[:object_ref] != :nil
            pp_field("object_ref", node.value[:object_ref])
          end

          if node.value[:nuke_outer_whitespace]
            bool_field("nuke_outer_whitespace")
          end

          if node.value[:nuke_inner_whitespace]
            bool_field("nuke_inner_whitespace")
          end

          bool_field("self_closing") if node.value[:self_closing]
          pp_field("value", node.value[:value]) if node.value[:value]
          pp_field("children", node.children) if node.children.any?
        end
      end

      private

      def bool_field(name)
        q.breakable
        q.text(name)
      end

      def group(name)
        q.group do
          q.text("(")
          q.text(name)

          q.nest(2) { yield }
          q.breakable("")
          q.text(")")
        end
      end

      def pp_field(name, value)
        q.breakable
        q.text(name)
        q.text("=")
        q.pp(value)
      end

      def text_field(name, value)
        q.breakable
        q.text(name)
        q.text("=")
        q.text(value)
      end
    end
  end
end
