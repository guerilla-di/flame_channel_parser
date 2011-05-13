require "test/unit"
require "stringio"

require File.dirname(__FILE__) + "/../lib/flame_channel_parser"
D = 0.25

class TestFlameChannelParser < Test::Unit::TestCase

  def tabulate(enum)
    STDERR.flush
    enum.each{|tuple| STDERR.puts("%05d %04f" % tuple) }
  end
  
  def test_channel_with_constants
    constants = FlameChannelParser::Parser2011.new.parse(DATA).find{|c| c.name == "constants"}
    interp = FlameInterpolator.new(constants)
    values = (-5..116).map{|f| [f, interp.sample_at(f)] }
    
    #tabulate(values)
  end
  
  def test_simple_setup_from_2011
    channels_in_action = FlameChannelParser::Parser2011.new.parse(File.open("./snaps/FLEM_curves_example.action"))
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" }
    sampled = channels_in_action.find{|c| c.name == "position/y" }
    
    ref_i, sample_i = [reference, sampled].map{|c| FlameInterpolator.new(c) }
    
    value_tuples = (1..200).map do |f|  
      [f, ref_i.sample_at(f), sample_i.sample_at(f)]
    end
    
    value_tuples.each do | frame, ref, actual |
      assert_in_delta ref, actual, D, "At #{frame} Interpolated value should be in delta"
    end
  end
  
  def test_broken_tangents_setup_from_2011
    channels_in_action = FlameChannelParser::Parser2011.new.parse(File.open("./snaps/FLEM_BrokenTangents.action"))
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" }
    sampled = channels_in_action.find{|c| c.name == "position/y" }
    
    ref_i, sample_i = [reference, sampled].map{|c| FlameInterpolator.new(c) }
    
    # This is handy for plotting
    IO.popen("pbcopy", "w") do |buf|
      (1..125).map{|f| buf.puts  "%03f\t%03f" % [ref_i.sample_at(f), sample_i.sample_at(f)] }
    end
    
    value_tuples = (1..200).map do |f|  
      [f, ref_i.sample_at(f), sample_i.sample_at(f)]
    end
    
    value_tuples.each do | frame, ref, actual |
      assert_in_delta ref, actual, D, "At #{frame} Interpolated value should be in delta"
    end
  end
  
  def test_setup_from_2012
    channels_in_action = FlameChannelParser::Parser2012.new.parse(File.open("./snaps/FLEM_advanced_curve_example_FL2012.action"))
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" }
    sampled = channels_in_action.find{|c| c.name == "position/y" }
    
    ref_i, sample_i = [reference, sampled].map{|c| FlameInterpolator.new(c) }
    
    value_tuples = (1..330).map do |f|  
      [f, ref_i.sample_at(f), sample_i.sample_at(f)]
    end
    
    # This is handy for plotting
    IO.popen("pbcopy", "w") do |buf|
      (1..330).map{|f| buf.puts  "%03f\t%03f" % [ref_i.sample_at(f), sample_i.sample_at(f)] }
    end
    
    value_tuples.each do | frame, ref, actual |
      assert_in_delta ref, actual, D, "At #{frame} Interpolated value should be in delta"
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