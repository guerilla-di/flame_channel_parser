# Writes out a framecurve setup
class FlameChannelParser::FramecurveWriters::Kronos < FlameChannelParser::FramecurveWriters::SoftfxTimewarp
  TOKEN = Regexp.new('__INSERT_FRAME_ANIM__')
  
  def run_export(io)
    buf = StringIO.new
    w = FlameChannelParser::Builder.new(buf)
    w.channel("Frame") do | c |
      export_timing_channel(c, &Proc.new)
    end
    
    # Entab everything
    template = File.read(File.dirname(__FILE__) + "/templates/SampleKronos.F_Kronos")
    io.write(template.gsub(TOKEN, buf.string))
  end
end