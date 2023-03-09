# frozen_string_literal: true

require "test_helper"

class PlainTest < Minitest::Test
  def test_plain
    assert_format("plain")
  end

  def test_escapes_percent
    assert_format("\\%")
  end

  def test_escapes_period
    assert_format("\\.")
  end

  def test_unescapes
    assert_format("! hello")
  end

  def test_keeps_blank_lines
    assert_format(<<~HAML)
      plain

      plain
    HAML
  end

  def test_keeps_nested_blank_lines
    assert_format(<<~HAML)
      %div
        plain

        plain
    HAML
  end
end
