require "test/unit"
require File.dirname(__FILE__) + "/../lib/flame_channel_parser"

D = 0.001

class TestConstantFunction < Test::Unit::TestCase
  def test_segment
    seg = ConstantFunction.new(123.4)
    assert seg.defines?(-1), "The segment should define this frame"
    assert seg.defines?(4567), "The segment should define this frame"
    assert_equal 123.4, seg.value_at(123), "This is the segment's constant value"
  end
end


class TestConstantSegment < Test::Unit::TestCase
  def test_fail
    flunk
  end
end

class TestLinearSegment < Test::Unit::TestCase
  def test_fail
    flunk
  end
end

class TestHermiteSegment < Test::Unit::TestCase
  def test_fail
    flunk
  end
end

class TestNaturalSegment < Test::Unit::TestCase
  def test_fail
    flunk
  end
end


class TestConstantPrepolate < Test::Unit::TestCase
  def test_fail
    flunk
  end
end

class TestLinearPrepolate < Test::Unit::TestCase
  def test_fail
    flunk
  end
end

class TestLinearExtrapolate < Test::Unit::TestCase
  def test_fail
    flunk
  end
end

