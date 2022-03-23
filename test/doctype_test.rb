# frozen_string_literal: true

require "test_helper"

class DoctypeTest < Minitest::Test
  def test_basic
    assert_format("!!! Basic")
  end

  def test_frameset
    assert_format("!!! Frameset")
  end

  def test_mobile
    assert_format("!!! Mobile")
  end

  def test_rdfa
    assert_format("!!! RDFa")
  end

  def test_strict
    assert_format("!!! Strict")
  end

  def test_xml
    assert_format("!!! XML")
  end

  def test_encoding
    assert_format("!!! XML iso-8859-1")
  end

  def test_1_1
    assert_format("!!! 1.1")
  end

  def test_5
    assert_format("!!! 5")
  end

  def test_misc
    assert_format("!!! foo")
  end
end
