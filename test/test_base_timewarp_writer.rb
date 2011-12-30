require "helper"

class TestBaseTimewarpWriter < Test::Unit::TestCase
  def test_with_each_writer
    pack = []
    FlameChannelParser::FramecurveWriters::Base.with_each_writer do | w |
      pack.push(w)
    end
    assert_equal [FlameChannelParser::FramecurveWriters::SoftfxTimewarp,
     FlameChannelParser::FramecurveWriters::BatchTimewarp,
     FlameChannelParser::FramecurveWriters::Kronos], pack
  end
  
  def test_write_from_framecurve
    c = Framecurve::Curve.new(Framecurve::Tuple.new(10, 123.45), Framecurve::Tuple.new(15, 456.78))
    b = FlameChannelParser::FramecurveWriters::Base.new
    buf = StringIO.new
    b.run_export_from_framecurve(buf, c)
    assert_equal "10 123.45000\n11 190.11600\n12 256.78200\n13 323.44800\n14 390.11400\n15 456.78000\n", buf.string
  end
  
end