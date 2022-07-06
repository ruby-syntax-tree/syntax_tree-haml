# frozen_string_literal: true

class HamlTest < Minitest::Test
  def test_read
    assert_equal(File.read(__FILE__), SyntaxTree::Haml.read(__FILE__))
  end
end
