# frozen_string_literal: true

require "test_helper"

class TagTest < Minitest::Test
  def test_plain
    assert_format("%div")
  end

  def test_value
    assert_format("%div Hello, world!")
  end

  def test_class
    assert_format("%p.foo")
  end

  def test_class_multiple
    assert_format("%p.foo.bar.baz")
  end

  def test_id
    assert_format("%p#foo")
  end

  def test_classes_and_id
    assert_format("%p.foo.bar#baz")
  end

  def test_self_closing
    assert_format("%br/")
  end

  def test_whitespace_removal_left_single_line
    assert_format('%p>= "Foo\\nBar"')
  end

  def test_whitespace_removal_right_single_line
    assert_format('%p<= "Foo\\nBar"')
  end

  def test_whitespace_removal_right_multi_line
    assert_format(<<~HAML)
      %blockquote<
        %div
          Foo!
    HAML
  end

  def test_dynamic_attributes
    assert_format("%span{html_attrs('fr-fr')}")
  end

  def test_dynamic_attributes_nested_hash
    assert_format("%div{data: { controller: \"lesson-evaluation\" }}")
  end

  def test_dynamic_attributes_nested_hash_single_quotes
    with_single_quotes do
      assert_format(
        "%div{data: { controller: \"lesson-evaluation\" }}",
        "%div{data: { controller: 'lesson-evaluation' }}"
      )
    end
  end

  def test_dynamic_attributes_integers
    assert_format("%span{foo: 1}")
  end

  def test_dynamic_attributes_html_style
    assert_format("%img(title=@title alt=@alt)/")
  end

  def test_dynamic_attributes_boolean
    assert_format("%span(foo)", "%span{foo: true}")
  end

  def test_dynamic_attributes_strings
    assert_format(
      "%section(xml:lang=\"en\" title=\"title\")",
      "%section{\"xml:lang\": \"en\", title: \"title\"}"
    )
  end

  def test_dynamic_attributes_strings_single_quotes
    with_single_quotes do
      assert_format(
        "%section(xml:lang=\"en\" title=\"title\")",
        "%section{'xml:lang': 'en', title: 'title'}"
      )
    end
  end

  def test_dynamic_attributes_with_at
    assert_format("%span{\"@click\": \"open = true\"}")
  end

  def test_static_attributes
    assert_format("%span{:foo => \"bar\"}", "%span{foo: \"bar\"}")
  end

  def test_object_reference
    assert_format(<<~HAML)
      %div[@user, :greeting]
        %bar[290]/
        Hello!
    HAML
  end

  def test_long_declaration_before_text
    long = "a" * 80

    assert_format("%button{ data: { current: #{long} } } foo", <<~HAML)
      %button{
        data: {
          current: #{long}
        }
      }
        foo
    HAML
  end

  def test_long_declaration_before_text_without_parser
    long = "a" * 80

    ::Haml::AttributeParser.stub(:available?, false) do
      assert_format("%button{ data: { current: #{long} } } foo", <<~HAML)
        %button{ data: { current: #{long} } }
          foo
      HAML
    end
  end

  def test_quotes_in_strings
    assert_format(
      "%div{title: 'escape \" quotes'}",
      "%div{title: \"escape \\\" quotes\"}"
    )
  end

  def test_interpolation_in_value
    assert_format("%p <small>hello</small>\"\#{1 + 2} little pigs\"")
  end

  private

  def with_single_quotes
    quote = SyntaxTree::Formatter::OPTIONS[:quote]
    SyntaxTree::Formatter::OPTIONS[:quote] = "'"

    begin
      yield
    ensure
      SyntaxTree::Formatter::OPTIONS[:quote] = quote
    end
  end
end
