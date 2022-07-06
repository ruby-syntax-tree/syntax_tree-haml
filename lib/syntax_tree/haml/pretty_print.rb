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
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#doctype-
      def visit_doctype(node)
        q.group(2, "(doctype", ")") do
          q.breakable
  
          if DOCTYPE_TYPES.key?(node.value[:type])
            q.text("type=")
            q.pp(node.value[:type])
          elsif DOCTYPE_VERSIONS.include?(node.value[:version])
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
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#filter
      def visit_filter(node)
        q.group(2, "(filter", ")") do
          q.breakable
          q.text("name=")
          q.text(node.value[:name])
  
          q.breakable
          q.text("text=")
          q.pp(node.value[:text])
        end
      end
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#haml-comments--
      def visit_haml_comment(node)
        q.group(2, "(haml_comment", ")") do
          q.breakable
          q.text("text=")
          q.pp(node.value[:text])
        end
      end
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#plain-text
      def visit_plain(node)
        q.group(2, "(plain", ")") do
          q.breakable
          q.text("text=")
          q.pp(node.value[:text])
        end
      end
  
      # Visit the root node of the AST.
      def visit_root(node)
        q.group(2, "(root", ")") do
          if node.children.any?
            q.breakable
            q.text("children=")
            q.pp(node.children)
          end
        end
      end
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#inserting_ruby
      def visit_script(node)
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
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#running-ruby--
      def visit_silent_script(node)
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
  
      # Visit a tag node.
      def visit_tag(node)
        q.group(2, "(tag", ")") do
          q.breakable
          q.text("name=")
          q.pp(node.value[:name])
  
          if node.value[:attributes].any?
            q.breakable
            q.text("attributes=")
            q.pp(node.value[:attributes])
          end
  
          if node.value[:dynamic_attributes].new
            q.breakable
            q.text("dynamic_attributes.new=")
            q.pp(node.value[:dynamic_attributes].new)
          end
  
          if node.value[:dynamic_attributes].old
            q.breakable
            q.text("dynamic_attributes.old=")
            q.pp(node.value[:dynamic_attributes].old)
          end
  
          if node.value[:object_ref] != :nil
            q.breakable
            q.text("object_ref=")
            q.pp(node.value[:object_ref])
          end
  
          if node.value[:nuke_outer_whitespace]
            q.breakable
            q.text("nuke_outer_whitespace")
          end
  
          if node.value[:nuke_inner_whitespace]
            q.breakable
            q.text("nuke_inner_whitespace")
          end
  
          if node.value[:self_closing]
            q.breakable
            q.text("self_closing")
          end
  
          if node.value[:value]
            q.breakable
            q.text("value=")
            q.pp(node.value[:value])
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
