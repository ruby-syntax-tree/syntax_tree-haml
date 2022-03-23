# frozen_string_literal: true

require "test_helper"

class SilentScriptTest < Minitest::Test
  def test_silent_script
    assert_format("- foo")
  end

  def test_case_when_else
    assert_format(<<~HAML)
      - case foo
      - when bar
        bar
      - when baz
        baz
      - else
        qux
    HAML
  end

  def test_case_in
    assert_format(<<~HAML)
      - case foo
      - in bar
        bar
      - in baz
        baz
    HAML
  end

  def test_if_else
    assert_format(<<~HAML)
      - if foo
        foo
      - elsif bar
        bar
      - else
        baz
    HAML
  end

  def test_unless_else
    assert_format(<<~HAML)
      - unless foo
        foo
      - elsif bar
        bar
      - else
        baz
    HAML
  end

  def test_while
    assert_format(<<~HAML)
      - while foo
        - while bar
          baz
    HAML
  end
end
