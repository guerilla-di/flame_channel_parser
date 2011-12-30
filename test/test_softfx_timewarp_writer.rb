require "helper"

class TestSoftfxTimewarpWriter < Test::Unit::TestCase
  def test_simple_export
    buf = StringIO.new
    w = FlameChannelParser::FramecurveWriters::SoftfxTimewarp.new
    w.run_export(buf) do | key_writer |
      key_writer.key(1, 40)
      key_writer.key(15, 56)
      key_writer.key(21, 63)
      key_writer.key(102, 102)
    end
    assert_same_buffer File.open(File.dirname(__FILE__) + "/timewarp_export_samples/SoftFX.timewarp"), buf
  end
  
end