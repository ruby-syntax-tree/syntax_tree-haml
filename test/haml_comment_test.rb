# frozen_string_literal: true

class HamlCommentTest < Minitest::Test
  def test_empty
    assert_format("-#")
  end

  def test_same_line
    assert_format("-# comment")
  end

  def test_multi_line
    assert_format(<<~HAML)
      -#
        this is a
          # multi line
        comment
    HAML
  end

  def test_spacing_same_line
    assert_format("-#       foobar      ", "-# foobar")
  end
end
