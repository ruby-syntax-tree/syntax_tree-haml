# frozen_string_literal: true

class SyntaxTree < Ripper
  module Haml
    class Tag
      LiteralHashValue = Struct.new(:value)

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
                  q.text(Tag.hash_key(key))
                  q.text(" ")

                  if value.is_a?(Hash)
                    format_value(q, value, level + 1)
                  else
                    q.text(Tag.hash_value(value))
                  end
                end
              end
            end

            q.breakable(level == 0 ? "" : " ")
            q.text("}")
          end
        end
      end

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def format(q)
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
          return Haml.with_children(node, q) do
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

        Haml.with_children(node, q) do
          align = 0

          parts.each do |part|
            part.format(q, align)
            align += part.length
          end
        end
      end

      def pretty_print(q)
        q.group(2, "(tag", ")") do
          q.breakable
          q.text("attributes=")
          q.pp(node.value[:attributes])

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

      private

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
    end
  end
end
