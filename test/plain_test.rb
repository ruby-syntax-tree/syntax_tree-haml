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
end
