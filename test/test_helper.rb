# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$:.unshift(File.expand_path("../lib", __dir__))
require "syntax_tree/haml"
require "minitest/autorun"

class Minitest::Test
  private

  def assert_format(source, expected = nil)
    # Adding a bit of code here just to make sure the pretty-printing gets
    # executed as part of this. Not going to actually assert against it since
    # it's more of a nice-to-have and the actual format is not strict.
    visitor = SyntaxTree::Haml::PrettyPrint.new(PP.new(+"", 80))
    SyntaxTree::Haml.parse(source).accept(visitor)

    # Here we perform the actual assertion by making sure that the formatted
    # result is what we expect.
    assert_equal(
      (expected || source).strip,
      SyntaxTree::Haml.format(source.dup).strip
    )
  end
end
