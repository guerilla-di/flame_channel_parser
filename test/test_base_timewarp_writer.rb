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
  
end