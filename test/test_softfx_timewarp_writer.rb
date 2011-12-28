require "./helper"

class TestSoftfxTimewarpWriter < Test::Unit::TestCase
  def test_simple_export
    buf = StringIO.new
    w = FlameChannelParser::FramecurveWriters::SoftfxTimewarp.new
    w.run_export(buf) do | key_writer |
      key_writer.key(1, 123)
      key_writer.key(15, 124)
      key_writer.key(19, 200)
    end
    
    assert_same_buffer File.open(File.dirname(__FILE__) + "/timewarp_export_samples/SoftFX.timewarp"), buf
  end
  
end