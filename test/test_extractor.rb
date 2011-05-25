require "test/unit"
require "stringio"

require File.dirname(__FILE__) + "/../lib/flame_channel_parser"

class TestExtractor < Test::Unit::TestCase
  def test_basic_op
    io = StringIO.new
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", :destination => io)
    assert_equal File.read(File.dirname(__FILE__) + "/snaps/RefT_Steadicam_Extraction.txt"), io.string
  end
  
  def test_frame_overrides
    io = StringIO.new
    o = {:destination => io, :start_frame => 19, :end_frame => 347 }
    FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", o)
    
    assert_equal File.read(File.dirname(__FILE__) + "/snaps/RefT_Steadicam_Extraction_F19_to_347.txt"), io.string
  end
  
  def test_raises_on_Missing_channel
    assert_raise(FlameChannelParser::Extractor::ChannelNotFoundError) do
      FlameChannelParser::Extractor.extract(File.dirname(__FILE__) + "/snaps/RefT_Steadicam.timewarp", :channel => "foo/bar")
    end
  end
end