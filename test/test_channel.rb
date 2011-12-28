require "./helper"

D = 0.001

class TestChannel < Test::Unit::TestCase
  def test_responds_to_array_methods
    c = FlameChannelParser::Channel.new("b/c", "d", "f")
    [:empty?, :length, :each, :[], :push, :<<].each {|m| assert c.respond_to?(m) }
  end
  
  def test_path_for_present_nodename
    c = FlameChannelParser::Channel.new("position/x", "Axis", "axis1")
    assert_equal "axis1/position/x", c.path
  end
  
  def test_path_for_absent
    c = FlameChannelParser::Channel.new("Frame/Frame", nil, nil)
    assert_equal "Frame/Frame", c.path
  end
  
end