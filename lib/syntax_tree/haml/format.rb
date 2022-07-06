# frozen_string_literal: true

module SyntaxTree
  module Haml
    class Format < Visitor
      attr_reader :q

      def initialize(q)
        @q = q
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#html-comments-
      def visit_comment(node)
        with_children(node) do
          q.text("/")
          q.text("!") if node.value[:revealed]
  
          if node.value[:conditional]
            q.text(node.value[:conditional])
          elsif node.value[:text]
            q.text(" #{node.value[:text]}")
          end
        end
      end
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#doctype-
      def visit_doctype(node)
        parts = ["!!!"]
  
        parts <<
          if DOCTYPE_TYPES.key?(node.value[:type])
            DOCTYPE_TYPES[node.value[:type]]
          elsif DOCTYPE_VERSIONS.include?(node.value[:version])
            node.value[:version]
          else
            node.value[:type]
          end
  
        parts << node.value[:encoding] if node.value[:encoding]
        q.text(parts.join(" "))
      end
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#filter
      def visit_filter(node)
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
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#haml-comments--
      def visit_haml_comment(node)
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
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#plain-text
      def visit_plain(node)
        text = node.value[:text]
        q.text("\\") if escaped?(text)
        q.text(text)
      end
  
      # Visit the root node of the AST.
      def visit_root(node)
        node.children.each do |child|
          visit(child)
          q.breakable(force: true)
        end
      end
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#inserting_ruby
      def visit_script(node)
        with_children(node) do
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
  
      # https://haml.info/docs/yardoc/file.REFERENCE.html#running-ruby--
      def visit_silent_script(node)
        q.group do
          q.text("- ")
          q.text(node.value[:text].strip)
  
          node.children.each do |child|
            if continuation?(node, child)
              q.breakable(force: true)
              visit(child)
            else
              q.indent do
                q.breakable(force: true)
                visit(child)
              end
            end
          end
        end
      end
  
      LiteralHashValue = Struct.new(:value)
  
      class PlainPart < Struct.new(:value)
        def format(q, align)
          q.text(value)
        end
  
        def length
          value.length
        end
      end
  
      class PrefixPart < Struct.new(:prefix, :value)
        def format(q, align)
          q.text("#{prefix}#{value}")
        end
  
        def length
          prefix.length + value.length
        end
      end
  
      class HTMLAttributesPart
        attr_reader :values
  
        def initialize(raw)
          @values =
            raw[1...-1].split(",").to_h do |keypair|
              keypair[1..-1].split("\" => ")
            end
        end
  
        def format(q, align)
          q.group do
            q.text("(")
            q.nest(align) do
              q.seplist(values, -> { q.fill_breakable }, :each_pair) do |key, value|
                q.text("#{key}=#{value}")
              end
            end
            q.text(")")
          end
        end
  
        def length
          values.sum { |key, value| key.length + value.length + 3 }
        end
      end
  
      class HashAttributesPart < Struct.new(:values)
        def format(q, align)
          format_value(q, values)
        end
  
        def length
          values.sum do |key, value|
            key.length + (value.is_a?(String) ? value : value.to_s).length + 3
          end
        end
  
        private
  
        def format_value(q, hash, level = 0)
          q.group do
            q.text("{")
            q.indent do
              q.group do
                q.breakable(level == 0 ? "" : " ")
                q.seplist(hash, nil, :each_pair) do |key, value|
                  q.text(Format.hash_key(key))
                  q.text(" ")
  
                  if value.is_a?(Hash)
                    format_value(q, value, level + 1)
                  else
                    q.text(Format.hash_value(value))
                  end
                end
              end
            end
  
            q.breakable(level == 0 ? "" : " ")
            q.text("}")
          end
        end
      end
  
      def self.hash_key(key)
        key.match?(/^@|[-:]/) ? "\"#{key}\":" : "#{key}:"
      end
  
      def self.hash_value(value)
        case value
        when LiteralHashValue
          value.value
        when String
          "\"#{Quotes.normalize(value, "\"")}\""
        else
          value.to_s
        end
      end

      # Visit a tag node.
      def visit_tag(node)
        parts = []
  
        # If we have a tag that isn't a div, then we need to print out that
        # name of that tag first. If it is a div, first we'll check if there
        # are any other things that would force us to print out the div
        # explicitly, and otherwise we'll leave it off.
        if node.value[:name] != "div"
          parts << PrefixPart.new("%", node.value[:name])
        end
  
        # If we have a class attribute, then we're going to print that here
        # using the special class syntax.
        if node.value[:attributes].key?("class")
          parts << PrefixPart.new(".", node.value[:attributes]["class"].tr(" ", "."))
        end
  
        # If we have an id attribute, then we're going to print that here
        # using the special id syntax.
        if node.value[:attributes].key?("id")
          parts << PrefixPart.new("#", node.value[:attributes]["id"])
        end
  
        # If we're using dynamic attributes on this tag, then they come in as
        # a string that looks like the output of Hash#inspect from Ruby. So
        # here we're going to split it all up and print it out nicely.
        if node.value[:dynamic_attributes].new
          parts << HTMLAttributesPart.new(node.value[:dynamic_attributes].new)
        end
  
        # If there are any static attributes that are not class or id (because
        # we already took care of those), then we're going to print them out
        # here.
        static = node.value[:attributes].reject { |key, _| key == "class" || key == "id" }
        parts << HashAttributesPart.new(static) if static.any?
  
        # If there are dynamic attributes that don't use the newer syntax, then
        # we're going to print them out here.
        if node.value[:dynamic_attributes].old
          parts << PlainPart.new("%div") if parts.empty?
  
          if ::Haml::AttributeParser.available?
            dynamic = parse_attributes(node.value[:dynamic_attributes].old)
            parts <<
              if dynamic.is_a?(LiteralHashValue)
                PlainPart.new(dynamic.value)
              else
                HashAttributesPart.new(dynamic)
              end
          else
            parts << PlainPart.new(node.value[:dynamic_attributes].old)
          end
        end
  
        # https://haml.info/docs/yardoc/file.REFERENCE.html#object-reference-
        if node.value[:object_ref] != :nil
          parts << PlainPart.new("%div") if parts.empty?
          parts << PlainPart.new(node.value[:object_ref])
        end
  
        # https://haml.info/docs/yardoc/file.REFERENCE.html#whitespace-removal--and-
        parts << PlainPart.new(">") if node.value[:nuke_outer_whitespace]
        parts << PlainPart.new("<") if node.value[:nuke_inner_whitespace]
  
        # https://haml.info/docs/yardoc/file.REFERENCE.html#empty-void-tags-
        parts << PlainPart.new("/") if node.value[:self_closing]
  
        # If there is a value part, then we're going to print slightly
        # differently as the value goes after the tag declaration.
        if node.value[:value]
          return with_children(node) do
            q.group do
              align = 0
  
              parts.each do |part|
                part.format(q, align)
                align += part.length
              end
            end
  
            q.indent do
              # Split between the declaration of the tag and the contents of the
              # tag.
              q.breakable("")
  
              if node.value[:parse] && node.value[:value].match?(/#[{$@]/)
                # There's a weird case here where if the value includes
                # interpolation and it's marked as { parse: true }, then we
                # don't actually want the = prefix, and we want to remove extra
                # escaping.
                q.if_break { q.text("") }.if_flat { q.text(" ") }
                q.text(node.value[:value][1...-1].gsub(/\\"/, "\""))
              elsif node.value[:parse]
                q.text("= ")
                q.text(node.value[:value])
              else
                q.if_break { q.text("") }.if_flat { q.text(" ") }
                q.text(node.value[:value])
              end
            end
          end
        end
  
        # In case none of the other if statements have matched and we're
        # printing a div, we need to explicitly add it back into the array.
        if parts.empty? && node.value[:name] == "div"
          parts << PlainPart.new("%div")
        end
  
        with_children(node) do
          align = 0
  
          parts.each do |part|
            part.format(q, align)
            align += part.length
          end
        end
      end
  
      private
  
      # When printing out sequences of silent scripts, sometimes subsequent nodes
      # will be continuations of previous nodes. In that case we want to dedent
      # them to match.
      def continuation?(node, child)
        return false if child.type != :silent_script
  
        case [node.value[:keyword], child.value[:keyword]]
        in ["case", "in" | "when" | "else"]
          true
        in ["if" | "unless", "elsif" | "else"]
          true
        else
          false
        end
      end
  
      # If a node comes in as the plain type but starts with one of the special
      # characters that haml parses, then we need to escape it with a \ when
      # printing.
      def escaped?(text)
        ::Haml::Parser::SPECIAL_CHARACTERS.any? do |special|
          text.start_with?(special)
        end
      end
  
      # Take a source string and attempt to parse it into a set of attributes that
      # can be used to format the source.
      def parse_attributes(source)
        case Ripper.sexp(source)
        in [:program, [[:hash, *], *]] if parsed = ::Haml::AttributeParser.parse(source)
          parsed.to_h { |key, value| [key, parse_attributes(value)] }
        in [:program, [[:string_literal, *], *]]
          source[1...-1]
        else
          LiteralHashValue.new(source)
        end
      end
  
      def with_children(node)
        if node.children.empty?
          q.group { yield }
        else
          q.group do
            q.group { yield }
            q.indent do
              node.children.each do |child|
                q.breakable(force: true)
                visit(child)
              end
            end
          end
        end
      end
    end
  end
end
