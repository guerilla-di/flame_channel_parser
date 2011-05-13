require "test/unit"

class TestFlameChannelParser < Test::Unit::TestCase
  D = 0.0001
  
  def test_parsing
    data = File.open(File.dirname(__FILE__) + "/sample_channel.dat")
    channels = FlameChannelParser.parse(data)
    assert_kind_of Array, channels
    assert_equal 1, channels.length, "Should find one channel"
    
    assert_kind_of FlameChannelParser::Parser2011::ChannelBlock, channels[0]
    
    ch = channels[0]
    assert_equal 4, ch.length
    
    peculiar_key = ch[1]
    assert_in_delta D, 858.177, peculiar_key.value
    assert_in_delta D, 2.31503, peculiar_key.left_slope
    assert_in_delta D, 2.31503, peculiar_key.right_slope
    assert_equal :constant, peculiar_key.interpolation
  end
  
  def test_action
    f = File.open(File.dirname(__FILE__) + "/snaps/FLEM_curves_example.action")
    channels = FlameChannelParser.parse(f)
    
    assert_kind_of Array, channels
    assert_equal 65, channels.length, "Should find 65 channels"
    channels.reject!{|c| c.length < 2 }
    assert_equal 2, channels.length, "Should have 2 channels with more than 2 keyframes"
    last_chan = channels[-1]
    assert_equal "position/y", last_chan.name
    assert_equal 6, last_chan.length
  end
  
  def test_action_from_2012
    f = File.open(File.dirname(__FILE__) + "/snaps/FLEM_advanced_curve_example_FL2012.action")
    channels = FlameChannelParser.parse(f)
    
    assert_kind_of Array, channels
    assert_equal 65, channels.length, "Should find 65 channels"
    channels.reject!{|c| c.length < 2 }
    assert_equal 2, channels.length, "Should have 2 channels with more than 2 keyframes"
    
    last_chan = channels[-1]
    assert_equal "position/y", last_chan.name
    assert_equal 9, last_chan.length
  end
  
end