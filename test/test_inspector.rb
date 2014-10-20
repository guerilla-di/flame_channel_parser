require "helper"

class TestInspector < Test::Unit::TestCase
  REF_OUTPUT_PATH = File.dirname(__FILE__) + "/test_inspector_ref_output.txt"

  def test_parsing_baked_timewarp_from_2011
    data = File.open(File.dirname(__FILE__) + "/snaps/TW.timewarp")
    channels = FlameChannelParser.parse(data)
    
    inspector = FlameChannelParser::Inspector.new(channels)
    output = ''
    
    inspector.pretty_print(StringIO.new(output))
    
    ref = File.read(REF_OUTPUT_PATH)
    assert_equal ref, output
  end
end
