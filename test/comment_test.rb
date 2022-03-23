# frozen_string_literal: true

require "test_helper"

class CommentTest < Minitest::Test
  def test_single_line
    assert_format(<<~HAML)
      / This is the peanutbutterjelly element
    HAML
  end

  def test_multi_line
    assert_format(<<~HAML)
      /
        This doesn't render, because it's commented out!
    HAML
  end

  def test_conditional
    assert_format(<<~HAML)
      /[if IE]
        Get Firefox
    HAML
  end

  def test_revealed
    assert_format(<<~HAML)
      /![if !IE]
        You are not using Internet Explorer, or are using version 10+.
    HAML
  end
end
