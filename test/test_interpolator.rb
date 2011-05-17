require "test/unit"
require "stringio"

require File.dirname(__FILE__) + "/../lib/flame_channel_parser"

class TestInterpolator < Test::Unit::TestCase
  DELTA = 0.05
  
  def send_curves_to_clipboard(range, ref_i, sample_i)
    # This is handy for plotting
    IO.popen("pbcopy", "w") do | buf |
      range.map{|f| buf.puts "%03f\t%03f" % [ref_i.sample_at(f), sample_i.sample_at(f)] }
    end
  end
  
  def assert_same_interpolation(range, ref_channel, sample_channel)
    ref_i, sample_i = [ref_channel, sample_channel].map{|c| FlameChannelParser::Interpolator.new(c) }
    
    value_tuples = range.map do |f|  
      [f, ref_i.sample_at(f), sample_i.sample_at(f)]
    end
    
    begin
      value_tuples.each do | frame, ref, actual |
        assert_in_delta ref, actual, DELTA, "At #{frame} interpolated value should be in delta"
      end
    rescue Test::Unit::AssertionFailedError => e
      STDERR.puts "Curves were not the same so I will now copy the two curves to the clipboard"
      send_curves_to_clipboard(range, ref_i, sample_i)
      raise e
    end
  end
  
  def test_channel_with_constants
    data = File.open(File.dirname(__FILE__) + "/channel_with_constants.dat")
    constants = FlameChannelParser.parse(data).find{|c| c.name == "constants"}
    interp =  FlameChannelParser::Interpolator.new(constants)
    
    vs = [770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41,
      770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 770.41, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 858.177, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 939.407, 1017.36, 1017.36]
    
    values = (-5..116).map{|f| interp.sample_at(f) }
    assert_equal vs, values
  end
  
  def test_baked_timewarp_from_2011
    data = File.open(File.dirname(__FILE__) + "/snaps/TW.timewarp")
    chan = FlameChannelParser.parse(data).find{|c| c.name == "Timing/Timing"}
    sampler = FlameChannelParser::Interpolator.new(chan)
    
    assert_equal 1, sampler.first_defined_frame
    assert_equal 816, sampler.last_defined_frame
  end
  
  def test_simple_setup_from_2011
    data = File.open(File.dirname(__FILE__) + "/snaps/FLEM_curves_example.action")
    channels_in_action = FlameChannelParser::Parser2011.new.parse(data)
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" && c.length > 2}
    sampled = channels_in_action.find{|c| c.name == "position/y"  && c.length > 2}
    assert_same_interpolation(1..200, reference, sampled)
  end
  
  def test_broken_tangents_setup_from_2011
    data = File.open(File.dirname(__FILE__) + "/snaps/FLEM_BrokenTangents.action")
    channels_in_action = FlameChannelParser.parse(data)
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" }
    sampled = channels_in_action.find{|c| c.name == "position/y" }
    assert_same_interpolation(1..200, reference, sampled)
  end
  
  def test_setup_moved_from_2011_to_2012_parses_the_same
    data = File.open(File.dirname(__FILE__) + "/snaps/FLEM_curves_example.action")
    data_2012 = File.open(File.dirname(__FILE__) + "/snaps/FLEM_curves_example_migrated_to_2012.action")
    
    ref = FlameChannelParser.parse(data).find{|e| e.name == "position/x" && e.length > 12 }
    sampled = FlameChannelParser.parse(data_2012).find{|e| e.name == "position/y" && e.length > 5 }
    
    assert_same_interpolation(1..200, ref, sampled)
  end
  
  def test_setup_from_2012_with_beziers
    data = File.open(File.dirname(__FILE__) + "/snaps/FLEM_advanced_curve_example_FL2012.action")
    channels_in_action = FlameChannelParser.parse(data)
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" && c.length > 2 }
    sampled = channels_in_action.find{|c| c.name == "position/y" && c.length > 2 }
    assert_same_interpolation(1..330, reference, sampled)
  end
end