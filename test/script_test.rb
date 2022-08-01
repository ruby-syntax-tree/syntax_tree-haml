# frozen_string_literal: true

require "test_helper"

class ScriptTest < Minitest::Test
  def test_script
    assert_format("= foo")
  end

  def test_preserve
    assert_format("~ foo")
  end

  def test_escape_html
    assert_format("&= foo")
  end

  def test_preserve_escape_html
    assert_format("&~ foo")
  end

  def test_unescape
    assert_format("!= hello")
  end
end
