# frozen_string_literal: true

require "test_helper"

class FilterTest < Minitest::Test
  def test_self
    assert_format(<<~HAML)
      :haml
        -# comment
    HAML
  end

  def test_custom
    assert_format(<<~HAML)
      :python
        def foo:
          bar
    HAML
  end

  def test_javascript
    assert_format(<<~HAML)
      :javascript
        1 + 1;
    HAML
  end

  def test_does_not_add_blank_lines
    assert_format(<<~HAML)
      %html
        %head
          :javascript
            console.log("This is inline script.");
        %body
          = yield
    HAML
  end

  def test_maintains_blank_lines
    assert_format(<<~HAML)
      %html
        %head
          :javascript
            console.log("This is inline script.");

        %body
          = yield
    HAML
  end
end
