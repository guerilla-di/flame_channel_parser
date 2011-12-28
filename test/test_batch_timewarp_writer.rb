require "./helper"

class TestBatchTimewarpWriter < Test::Unit::TestCase
  def test_simple_export
    buf = StringIO.new
    w = FlameChannelParser::FramecurveWriters::BatchTimewarp.new
    w.run_export(buf) do | key_writer |
      key_writer.key(1, 123)
      key_writer.key(15, 124)
      key_writer.key(19, 200)
    end
    
    puts buf.string
    flunk
  end
  
end