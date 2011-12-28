require "./helper"

class TestKronosTimewarpWriter < Test::Unit::TestCase
  def test_simple_export
    buf = StringIO.new
    w = FlameChannelParser::FramecurveWriters::Kronos.new
    w.run_export(buf) do | key_writer |
      key_writer.key(1, 123)
      key_writer.key(15, 124)
      key_writer.key(19, 200)
    end
    
    assert_same_buffer File.open(File.dirname(__FILE__) + "/timewarp_export_samples/Kronos.F_Kronos"), buf
  end
  
end