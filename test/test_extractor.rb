require "test/unit"
require "stringio"

require File.dirname(__FILE__) + "/../lib/flame_channel_parser"

class TestExtractor < Test::Unit::TestCase
  def test_basic_operation
    io = StringIO.new
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", :destination => io)
    assert_equal File.read(File.dirname(__FILE__) + "/snaps/RefT_Steadicam_Extraction.txt"), io.string
  end
  
  def test_channel_selection_by_path_raises_with_not_animated_channel_and_no_start_and_end
    io = StringIO.new
    ops = {:destination => io, :channel => "axis1/position/z"}
    assert_raise(FlameChannelParser::Extractor::NoKeyframesError) do
      FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/FLEM_curves_example_migrated_to_2012.action", ops)
    end
  end
  
  def test_channel_selection_by_path_outputs_properly
    io = StringIO.new
    ops = {:destination => io, :channel => "axis1/position/y"}
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/FLEM_curves_example_migrated_to_2012.action", ops)
    line_re = /12	-101.80433/
    assert_match line_re , io.string
  end
  
  def test_extraction_succeeds_for_tw_with_odd_end
    io = StringIO.new
    ops = {:start_frame => 1, :end_frame => 504, :destination => io, :channel => "Timing/Timing"}
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/timewarp_where_interp_fails_at_end.timewarp", ops)
    line_re = /1\t-7.00000\n2\t-6.00000/
    assert_match line_re , io.string
  end
  
  def test_frame_overrides
    io = StringIO.new
    o = {:destination => io, :start_frame => 19, :end_frame => 347 }
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", o)
    
    assert_equal File.read(File.dirname(__FILE__) + "/snaps/RefT_Steadicam_Extraction_F19_to_347.txt"), io.string
  end
  
  def test_constant_channels_need_domain_of_definition_on_time
    assert_raise(FlameChannelParser::Extractor::NoKeyframesError) do
      FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", :channel => "Mix/Mix")
    end
  end
  
  def test_raises_on_Missing_channel
    assert_raise(FlameChannelParser::Extractor::ChannelNotFoundError) do
      FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", :channel => "foo/bar")
    end
  end
  
end