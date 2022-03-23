# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$:.unshift(File.expand_path("../lib", __dir__))
require "syntax_tree/haml"
require "minitest/autorun"

class Minitest::Test
  private

  def assert_format(source, expected = nil)
    assert_equal(
      (expected || source).strip,
      SyntaxTree::Haml.format(source.dup).strip
    )
  end
end
