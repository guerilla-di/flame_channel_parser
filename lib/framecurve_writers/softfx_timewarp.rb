# Writes out a framecurve setup
class FlameChannelParser::FramecurveWriters::SoftfxTimewarp
  DATETIME_FORMAT = '%a %b %d %H:%M:%S %Y'
  TIME = Time.local(2011,12,28,14,50,05)
  
  class KeyWriter
    attr_reader :num_keys
    def initialize(writer)
      @w = writer
      @num_keys = 0
    end
    
    def key(at, value)
      @w.key(@num_keys) do | k |
        k.frame at
        k.value value.to_f
        k.interpolation :linear
        k.left_slope 2.4
        k.right_slope 2.4
      end
      @num_keys += 1
    end
  end
  
  def run_export(io)
    w = FlameChannelParser::Builder.new(io)
    
    w.timewarp_file_version "1.0"
    w.creation_date(TIME.strftime(DATETIME_FORMAT))
    w.linebreak(2)
    w.fields 0
    w.origin 1
    w.render_type false
    w.sampling_step 0
    w.interpolation 0
    w.flow_quality 0
    w.linebreak!(2)
    
    
    w.animation do | anim |
      anim.channel("Speed") do # empty, will be autocomputed
      end
      anim.channel("Timing/Timing") do | c |
        export_timing_channel(c, &Proc.new)
      end
    end
    
  end
  
  private
  
  def export_timing_channel(c, &blk)
    buf = StringIO.new
    channel = FlameChannelParser::Builder.new(buf)
    kw = KeyWriter.new(channel)
    
    # First accumulate all the keyframes
    yield(kw)
    
    c.extrapolation :constant
    c.value 1
    c.key_version 1
    # And then we know how many keyframes we did, export that
    c.size kw.num_keys
    # ... and after that the keyframes
    c << buf.string
  end
end