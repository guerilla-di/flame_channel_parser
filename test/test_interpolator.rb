require "test/unit"
require "stringio"

require File.dirname(__FILE__) + "/../lib/flame_channel_parser"

class TestInterpolator < Test::Unit::TestCase
  DELTA = 0.01
  
  def test_channel_with_constants
    data = File.open(File.dirname(__FILE__) + "/channel_with_constants.dat")
    constants = FlameChannelParser::Parser2011.new.parse(data).find{|c| c.name == "constants"}
    interp =  FlameChannelParser::Interpolator.new(constants)
    values = (-5..116).map{|f| [f, interp.sample_at(f)] }
  end
  
  def test_simple_setup_from_2011
    data = File.open(File.dirname(__FILE__) + "/snaps/FLEM_curves_example.action")
    channels_in_action = FlameChannelParser::Parser2011.new.parse(data)
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" }
    sampled = channels_in_action.find{|c| c.name == "position/y" }
    
    ref_i, sample_i = [reference, sampled].map{|c| FlameChannelParser::Interpolator.new(c) }
    
    assert_equal 1, sample_i.first_defined_frame
    assert_equal 149, sample_i.last_defined_frame
    
    value_tuples = (1..200).map do |f|  
      [f, ref_i.sample_at(f), sample_i.sample_at(f)]
    end
    
    value_tuples.each do | frame, ref, actual |
      assert_in_delta ref, actual, DELTA, "At #{frame} Interpolated value should be in delta"
    end
  end
  
  def test_broken_tangents_setup_from_2011
    data = File.open(File.dirname(__FILE__) + "/snaps/FLEM_BrokenTangents.action")
    channels_in_action = FlameChannelParser.parse(data)
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" }
    sampled = channels_in_action.find{|c| c.name == "position/y" }
    
    ref_i, sample_i = [reference, sampled].map{|c| FlameChannelParser::Interpolator.new(c) }
    
    # This is handy for plotting
    IO.popen("pbcopy", "w") do |buf|
      (1..125).map{|f| buf.puts  "%03f\t%03f" % [ref_i.sample_at(f), sample_i.sample_at(f)] }
    end
    
    value_tuples = (1..200).map do |f|  
      [f, ref_i.sample_at(f), sample_i.sample_at(f)]
    end
    
    value_tuples.each do | frame, ref, actual |
      assert_in_delta ref, actual, DELTA, "At #{frame} Interpolated value should be in delta"
    end
  end
  
  def test_setup_from_2012
    data = File.open(File.dirname(__FILE__) + "/snaps/FLEM_advanced_curve_example_FL2012.action")
    channels_in_action = FlameChannelParser.parse(data)
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" }
    sampled = channels_in_action.find{|c| c.name == "position/y" }
    
    ref_i, sample_i = [reference, sampled].map{|c| FlameChannelParser::Interpolator.new(c) }
    
    value_tuples = (1..330).map do |f|  
      [f, ref_i.sample_at(f), sample_i.sample_at(f)]
    end
    
    # This is handy for plotting
    IO.popen("pbcopy", "w") do |buf|
      (1..330).map{|f| buf.puts  "%03f\t%03f" % [ref_i.sample_at(f), sample_i.sample_at(f)] }
    end
    
    value_tuples.each do | frame, ref, actual |
      assert_in_delta ref, actual, DELTA, "At #{frame} Interpolated value should be in delta"
    end
    
  end
end