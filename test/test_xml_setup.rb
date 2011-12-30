require "helper"


class TestXMLParser < Test::Unit::TestCase
  D = 0.0001
  
  def test_parsing_timewarp_from_2012
    data = File.open(File.dirname(__FILE__) + "/snaps/BatchTimewarp_ext1.timewarp_node")
    p = FlameChannelParser::XMLParser.new
    channels = p.parse(data)
    
    assert_equal 12, channels.length, "Should have pulled 12 channels"
    timing = channels.find{|c| c.path == "Timing"}
    
    assert_not_nil timing
    assert_kind_of FlameChannelParser::Channel, timing
    assert_equal 4, timing.length
    
    first_k = timing[0]
    assert first_k.has_2012_tangents?
    
    assert_in_delta D, 1, first_k.frame
    assert_in_delta D, 1, first_k.value
    assert_equal :hermite, first_k.curve_mode
    assert_equal :linear, first_k.curve_order
    assert_in_delta D, 8.666667, first_k.r_handle_x
    assert_in_delta D, 0.75, first_k.l_handle_y
  end
  
  def test_xml_detected
    data = File.open(File.dirname(__FILE__) + "/snaps/BatchTimewarp_ext1.timewarp_node")
    channels = FlameChannelParser.parse(data)
    assert_equal 12, channels.length, "Should have pulled 12 channels"
    timing = channels.find{|c| c.path == "Timing"}
    assert_not_nil timing
  end
end