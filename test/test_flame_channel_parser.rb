require "helper"

class TestFlameChannelParser < Test::Unit::TestCase
  D = 0.0001
  
  def test_parsing_baked_timewarp_from_2011
    data = File.open(File.dirname(__FILE__) + "/snaps/TW.timewarp")
    chan = FlameChannelParser.parse(data).find{|c| c.name == "Timing/Timing"}
    assert_equal 816, chan.length
    assert_equal 1, chan[0].frame
    assert_equal 816, chan[-1].frame
  end
  
  def test_parsing_kronos_setup
    data = File.open(File.dirname(__FILE__) + "/snaps/TW_TEST.F_Kronos")
    chans = FlameChannelParser.parse(data)
    assert_equal "Frame", chans[0].path
    assert_equal 12, chans[0].length
  end
  
  def test_parsing_with_block
    counter = 0
    f = File.open(File.dirname(__FILE__) + "/snaps/FLEM_curves_example.action")
    chans = FlameChannelParser.parse(f) do |channel| 
      counter += 1
      assert_kind_of FlameChannelParser::Channel, channel
    end
    assert_equal 65, counter, "Should find 65 channels"
  end
  
  def test_parsing_kronos_with_reports
    logging_console = ""
    data = File.open(File.dirname(__FILE__) + "/snaps/TW_TEST.F_Kronos")
    parser = FlameChannelParser::Parser.new
    parser.logger_proc = lambda do | log_message |
      logging_console << log_message
    end
    
    parser.parse(data)
    assert_match /Extracting keyframe 1 of 12/, logging_console
    assert_no_match /Extracting keyframe 0 of 12/, logging_console, "Keyframe indices should not start at zero"
  end
  
  def test_parsing
    data = File.open(File.dirname(__FILE__) + "/sample_channel.dat")
    channels = FlameChannelParser.parse(data)
    assert_kind_of Array, channels
    assert_equal 1, channels.length, "Should find one channel"
    
    assert_kind_of FlameChannelParser::Channel, channels[0]
    
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
    assert_equal "Axis", last_chan.node_type
    assert_equal "axis1", last_chan.node_name
    assert_equal "axis1/position/y", last_chan.path
    
    assert_equal 6, last_chan.length
    i = last_chan.to_interpolator
    assert_kind_of FlameChannelParser::Interpolator, i
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
  
  def test_action_migrated_to_2012
    f = File.open(File.dirname(__FILE__) + "/snaps/FLEM_curves_example_migrated_to_2012.action")
    channels = FlameChannelParser.parse(f)
    
    assert_kind_of Array, channels
    assert_equal 65, channels.length, "Should find 65 channels"
    channels.reject!{|c| c.length < 2 }
    assert_equal 2, channels.length, "Should have 2 channels with more than 2 keyframes"
    
    last_chan = channels[-1]
    assert_equal "position/y", last_chan.name
    assert_equal 6, last_chan.length
  end
  
end