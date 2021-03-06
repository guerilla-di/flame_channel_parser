require "helper"


class TestExtractor < Test::Unit::TestCase
  
  def test_basic_operation
    io = StringIO.new
    opts = {:destination => io}
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", opts)
    assert_equal File.read(File.dirname(__FILE__) + "/snaps/RefT_Steadicam_Extraction.txt"), io.string
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
  
  def test_properly_recognizes_timewarp_length_in_timewarp
    io = StringIO.new
    o = {:destination => io }
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/TW_015_010_v03.timewarp", o)
    lines = io.string.split("\n")
    
    assert_equal 476, lines.length, "Should have parsed out 476 frames even though animation curves go further"
  end
  
  def test_properly_recognizes_timewarp_length_in_action
    io = StringIO.new
    o = {:destination => io , :channel => "axis1/position/z"}
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/FLEM_BrokenTangents.action", o)
    lines = io.string.split("\n")
    
    assert_equal 125, lines.length, "Should have parsed out 125 frames even though animation curves go further"
  end
  
  def test_constant_channels_need_domain_of_definition_on_time
    opts = {:channel => "Mix/Mix", :on_curve_limits => true}
    
    assert_raise(FlameChannelParser::Extractor::NoKeyframesError) do
      FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", opts)
    end
  end
  
  def test_raises_on_Missing_channel
    assert_raise(FlameChannelParser::Extractor::ChannelNotFoundError) do
      FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", :channel => "foo/bar")
    end
  end
  
  def test_properly_uses_channel_length_for_range_detection_when_setup_length_is_not_give
    io = StringIO.new
    o = {:destination => io , :channel => "Frame"}
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/TW_TEST.F_Kronos", o)
    assert_equal 5000, io.string.split("\n").length, "Should have parsed out 5000 frames"
  end
end