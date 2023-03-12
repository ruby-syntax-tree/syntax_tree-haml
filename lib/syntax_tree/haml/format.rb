# frozen_string_literal: true

module SyntaxTree
  module Haml
    class Format < Visitor
      class Formatter < ::SyntaxTree::Formatter
        attr_reader :literal_lines

        def initialize(
          source,
          *rest,
          options: ::SyntaxTree::Formatter::Options.new
        )
          @literal_lines = {}
          source
            .lines
            .each
            .with_index(1) do |line, index|
              @literal_lines[index] = line.rstrip if line.start_with?("!")
            end

          super(source, *rest, options: options)
        end
      end

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

        parts << if DOCTYPE_TYPES.key?(node.value[:type])
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
            q.breakable_force
            first = true

            node.value[:text]
              .rstrip
              .each_line(chomp: true) do |line|
                if first
                  first = false
                else
                  q.breakable_force
                end

                q.text(line)
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
            q.breakable_force
            first = true

            text.each_line(chomp: true) do |line|
              if first
                first = false
              else
                q.breakable_force
              end

              q.text(line)
            end
          end
        else
          q.text(" #{text}")
        end
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#plain-text
      def visit_plain(node)
        if line = q.literal_lines[node.line]
          q.text(line)
        else
          text = node.value[:text]
          q.text("\\") if escaped?(text)
          q.text(text)
        end
      end

      # Visit the root node of the AST.
      def visit_root(node)
        previous_line = nil

        node.children.each do |child|
          q.breakable_force if previous_line && (child.line - previous_line) > 1
          previous_line = child.last_line

          visit(child)
          q.breakable_force
        end
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#inserting_ruby
      def visit_script(node)
        with_children(node) do
          if line = q.literal_lines[node.line]
            q.text(line)
          else
            q.text("&") if node.value[:escape_html]
            q.text(node.value[:preserve] ? "~" : "=")
            q.text(" ")
            q.text(node.value[:text].strip)
          end
        end
      end

      # https://haml.info/docs/yardoc/file.REFERENCE.html#running-ruby--
      def visit_silent_script(node)
        q.group do
          q.text("- ")
          q.text(node.value[:text].strip)

          node.children.each do |child|
            if continuation?(node, child)
              q.breakable_force
              visit(child)
            else
              q.indent do
                q.breakable_force
                visit(child)
              end
            end
          end
        end
      end

      LiteralHashValue = Struct.new(:value)

      # When formatting a tag, there are a lot of different kinds of things that
      # can be printed out. There's the tag name, the attributes, the content,
      # etc. This object is responsible for housing all of those parts.
      class PartList
        attr_reader :node, :parts

        def initialize(node)
          @node = node
          @parts = []
        end

        def <<(part)
          parts << part
        end

        def empty?
          parts.empty?
        end

        def format(q)
          if empty? && node.value[:name] == "div"
            # If we don't have any other parts to print and the tag is a div
            # then we need to make sure to add that to the beginning. Otherwise
            # it's implied by the presence of other operators.
            q.text("%div")
          else
            parts.inject(0) do |align, part|
              part.format(q, align)
              align + part.length
            end
          end
        end
      end

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
        class Separator
          def call(q)
            q.fill_breakable
          end
        end

        SEPARATOR = Separator.new

        attr_reader :values

        def initialize(raw)
          @values =
            raw[1...-1]
              .split(",")
              .to_h { |keypair| keypair[1..-1].split("\" => ") }
        end

        def format(q, align)
          q.group do
            q.text("(")
            q.nest(align) do
              q.seplist(values, SEPARATOR, :each_pair) do |key, value|
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
          quote = q.quote

          q.group do
            q.text("{")
            q.indent do
              q.group do
                level == 0 ? q.breakable_empty : q.breakable_space
                q.seplist(hash, nil, :each_pair) do |key, value|
                  if key.match?(/^@|[-:]/) && !key.match?(/^["']/)
                    q.text("#{quote}#{Quotes.normalize(key, quote)}#{quote}:")
                  else
                    q.text("#{key}:")
                  end

                  q.text(" ")

                  case value
                  when Hash
                    format_value(q, value, level + 1)
                  when LiteralHashValue
                    q.text(value.value)
                  when StringLiteral
                    value.format(q)
                  when String
                    q.text("#{quote}#{Quotes.normalize(value, quote)}#{quote}")
                  else
                    q.text(value.to_s)
                  end
                end
              end
            end

            level == 0 ? q.breakable_empty : q.breakable_space
            q.text("}")
          end
        end
      end

      # Visit a tag node.
      def visit_tag(node)
        parts = PartList.new(node)

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
          parts << PrefixPart.new(
            ".",
            node.value[:attributes]["class"].tr(" ", ".")
          )
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
        static =
          node.value[:attributes].reject do |key, _|
            key == "class" || key == "id"
          end

        parts << HashAttributesPart.new(static) if static.any?

        # If there are dynamic attributes that don't use the newer syntax, then
        # we're going to print them out here.
        if node.value[:dynamic_attributes].old
          parts << PlainPart.new("%div") if parts.empty?
          parts << parse_attributes(node.value[:dynamic_attributes].old)
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
        if (value = node.value[:value]) && !value.empty?
          with_children(node) do
            q.group { parts.format(q) }
            q.indent do
              # Split between the declaration of the tag and the contents of the
              # tag.
              q.breakable_empty

              if node.value[:parse]
                format_tag_value(q, value)
              else
                q.if_break { q.text("") }.if_flat { q.text(" ") }
                q.text(value)
              end
            end
          end
        else
          with_children(node) { parts.format(q) }
        end
      end

      private

      def format_tag_value(q, value)
        program = SyntaxTree.parse(value)
        if !program || program.statements.body.length > 1
          return q.text("= #{value}")
        end

        statement = program.statements.body.first
        formatter = SyntaxTree::Formatter.new(value, [], Float::INFINITY)
        formatter.format(statement)
        formatter.flush
        formatted = formatter.output.join

        if statement.is_a?(StringLiteral) && statement.parts.length > 1
          # There's a weird case here where if the value includes interpolation
          # and it's marked as { parse: true }, then we don't actually want the
          # = prefix, and we want to remove extra escaping.
          q.if_break { q.text("") }.if_flat { q.text(" ") }
          q.text(formatted[1...-1].gsub(/\\"/, "\""))
        else
          q.text("= #{formatted}")
        end
      rescue Parser::ParseError
        q.text("= #{value}")
      end

      # When printing out sequences of silent scripts, sometimes subsequent nodes
      # will be continuations of previous nodes. In that case we want to dedent
      # them to match.
      def continuation?(node, child)
        return false if child.type != :silent_script

        case node.value[:keyword]
        when "case"
          %w[in when else].include?(child.value[:keyword])
        when "if", "unless"
          %w[elsif else].include?(child.value[:keyword])
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

      # Take a source string and attempt to parse it into a set of attributes
      # that can be used to format the source.
      def parse_attributes(source)
        source = source.strip
        source = source.start_with?("{") ? source : "{#{source}}"

        program = SyntaxTree.parse(source)
        return PlainPart.new(source) if program.nil?

        node = program.statements.body.first
        return PlainPart.new(source) unless node.is_a?(HashLiteral)

        HashAttributesPart.new(parse_attributes_hash(source, node))
      rescue Parser::ParseError
        PlainPart.new(source)
      end

      def parse_attributes_hash(source, node, level = 1)
        node.assocs.to_h do |assoc|
          key =
            case assoc.key
            when StringLiteral
              format(assoc.key)
            when Label
              assoc.key.value.delete_suffix(":")
            when DynaSymbol
              format(assoc.key).delete_prefix(":")
            else
              format(assoc.key)
            end

          value =
            case assoc.value
            when HashLiteral
              parse_attributes_hash(source, assoc.value, level + 1)
            when StringLiteral
              assoc.value
            else
              LiteralHashValue.new(format(assoc.value, level * 2).lstrip)
            end

          [key, value]
        end
      end

      def format(node, column = 0)
        SyntaxTree::Formatter.format(+"", node, column)
      end

      def with_children(node)
        if node.children.empty?
          q.group { yield }
        else
          q.group do
            q.group { yield }
            q.indent do
              previous_line = nil

              node.children.each do |child|
                q.breakable_force

                if previous_line && (child.line - previous_line) > 1
                  q.breakable_force
                end

                visit(child)
                previous_line = child.last_line
              end
            end
          end
        end
      end
    end
  end
end
