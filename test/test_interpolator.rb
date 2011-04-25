require "test/unit"
require "flame_channel_parser"

class TestFlameChannelParser < Test::Unit::TestCase
  D = 0.0001
  
  def test_channel_with_constants
    constants = FlameChannelParser.new.parse(DATA).find{|c| c.name == "constants"}
    interp = FlameInterpolator.new(constants)
    
    values = {}
    
    (-5..116).map{|f| values[f] = interp.sample_at(f) }
    assert_equal 122, values.length
    
    assert_in_delta 770.41, values[-5], D, "Value at -5 should be extraped from the key at frame 1"
    
    (1...44).each do | at |
      assert_in_delta 770.41, values[at], D, "Value for frame #{at} should be in delta"
    end
    
    (44...74).each do | at |
      assert_in_delta 858.177, values[at],  D, "Value for frame #{at} should be in delta"
    end
    
    assert_not_nil values[116], "Value for frame 116 should have been provided"
    
    assert_in_delta 1017.36, values[116], D, "Value for frame 116 should be properly extrapolated"
    
  end
  
  def test_whole_thing
    channels_in_action = FlameChannelParser.new.parse(File.open("./snaps/FLEM_curves_example.action"))
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" }
    sampled = channels_in_action.find{|c| c.name == "position/y" }
    ref_i, sample_i = [reference, sampled].map{|c| FlameInterpolator.new(c) }
    
    value_tuples = (1..200).map do |f|  
      [ref_i.sample_at(f), sample_i.sample_at(f)]
    end
  end
end

__END__
Channel constants
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