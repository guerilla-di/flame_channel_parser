require "./helper"

class TestBatchTimewarpWriter < Test::Unit::TestCase
  def test_simple_export
    buf = StringIO.new
    w = FlameChannelParser::FramecurveWriters::BatchTimewarp.new
    w.run_export(buf) do | key_writer |
      key_writer.key(1, 15)
      key_writer.key(15, 50)
      key_writer.key(19, 102)
    end
    
    File.open(File.dirname(__FILE__) + "/timewarp_export_samples/BatchTW.timewarp_node", "wb"){|f| f.write(buf.string) }
    
    assert_same_buffer File.open(File.dirname(__FILE__) + "/timewarp_export_samples/BatchTW.timewarp_node"), buf
  end
  
end