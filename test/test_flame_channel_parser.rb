require "test/unit"
require "flame_channel_parser"

class TestFlameChannelParser < Test::Unit::TestCase
  D = 0.0001
  
  def test_parsing
    channels = FlameChannelParser.new.parse(DATA)
    assert_kind_of Array, channels
    assert_equal 1, channels.length, "Should find one channel"
    
    assert_kind_of FlameChannelParser::ChannelBlock, channels[0]
    
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
    channels = FlameChannelParser.new.parse(f)
    
    assert_kind_of Array, channels
    assert_equal 65, channels.length, "Should find 65 channels"
    channels.reject!{|c| c.length < 2 }
    assert_equal 2, channels.length, "Should have 2 channels with more than 2 keyframes"
    puts channels[0].inspect
  end
  
end

__END__


=begin
Here's how a Flame channel looks like
The Size will not be present if there are no keyframes

Channel tracker1/ref/x
	Extrapolation constant
	Value 770.41
	Size 4
	KeyVersion 1
	Key 0
		Frame 1
		Value 770.41
		Interpolation constant
		End
	Key 1
		Frame 44
		Value 858.177
		Interpolation constant
		RightSlope 2.31503
		LeftSlope 2.31503
		End
	Key 2
		Frame 74
		Value 939.407
		Interpolation constant
		RightSlope 2.24201
		LeftSlope 2.24201
		End
	Key 3
		Frame 115
		Value 1017.36
		Interpolation constant
		End
	Colour 50 50 50 
	End
=end