require "helper"

class TestTwextract < Test::Unit::TestCase
  
  def test_parse_with_interpolated_setup
    interpolated_io = StringIO.new
    FlameChannelParser::TimewarpExtractor.new.extract(File.dirname(__FILE__) + "/timewarp_examples/TW_TEST.F_Kronos", :destination => interpolated_io)
    assert_equal 83053, interpolated_io.pos
  end
  
  def test_parse_kronos_setup
    interpolated_io = StringIO.new
    baked_io = File.open(File.dirname(__FILE__) + "/timewarp_examples/TW_16_010_v01.output.txt")
    
    FlameChannelParser::TimewarpExtractor.new.extract(File.dirname(__FILE__) + "/timewarp_examples/TW_016_010_v01.timewarp", :destination => interpolated_io)
    assert_same_output(baked_io, interpolated_io)
  end
  
  def test_parse_batch_tw_setup
    interpolated_io = StringIO.new
    baked_io = File.open(File.dirname(__FILE__) + "/timewarp_examples/tw_batch_out.framecurve.txt")
    
    FlameChannelParser::TimewarpExtractor.new.extract(File.dirname(__FILE__) + "/snaps/BatchTimewarp_ext1.timewarp_node", :destination => interpolated_io)
    assert_same_output(baked_io, interpolated_io)
  end
  
  private
  
  D = 0.1
  
  # TODO: this one is not working properly
  def assert_same_output(ref, out)
    ref.rewind; out.rewind
    lineno = 1
    until (ref.eof? && out.eof?)
      ref_line, out_line = ref.gets, out.gets
      assert_equal ref_line, out_line, "Line #{lineno} should be the same"
      lineno += 1
    end
  end
  
end
