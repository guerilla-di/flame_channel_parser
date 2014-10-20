require "helper"

class TestInspector < Test::Unit::TestCase
  REF_TIMEWARP = File.dirname(__FILE__) + "/snaps/TW.timewarp"
  REF_TIMEWARP_OUTPUT_PATH = File.dirname(__FILE__) + "/test_inspector_ref_output_timewarp.txt"
  
  REF_STABILIZER = File.dirname(__FILE__) + '/stabilizer_examples/2014_cornerpin_points.stabilizer'
  REF_STABILIZER_OUTPUT_PATH = File.dirname(__FILE__) + "/test_inspector_ref_output_stabilizer.txt"
  
  def test_inspecting_baked_timewarp_from_2011
    data = File.open(REF_TIMEWARP)
    channels = FlameChannelParser.parse(data)
    
    inspector = FlameChannelParser::Inspector.new(channels)
    output = ''
    
    inspector.pretty_print(StringIO.new(output))
    
    #File.open(REF_TIMEWARP_OUTPUT_PATH, 'w'){|f| f << output }
    
    ref = File.read(REF_TIMEWARP_OUTPUT_PATH)
    assert_equal ref, output
  end
  
  def test_parsing_stabilizer_from_2014
    data = File.open(REF_STABILIZER)
    channels = FlameChannelParser.parse(data)
    
    inspector = FlameChannelParser::Inspector.new(channels)
    output = ''
    
    inspector.pretty_print(StringIO.new(output))
    
    #File.open(REF_STABILIZER_OUTPUT_PATH, 'w'){|f| f << output }
    
    ref = File.read(REF_STABILIZER_OUTPUT_PATH)
    assert_equal ref, output
  end
end
