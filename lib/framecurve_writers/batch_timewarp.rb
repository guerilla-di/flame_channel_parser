# Writes out a framecurve setup
class FlameChannelParser::FramecurveWriters::BatchTimewarp < FlameChannelParser::FramecurveWriters::SoftfxTimewarp
  DATETIME_FORMAT = '%a %b %d %H:%M:%S %Y'
  
  def run_export(io)
    w = FlameChannelParser::Builder.new(io)
    
    w.spark_file_version 1
    w.creation_date(Time.now.strftime(DATETIME_FORMAT))
    w.name "/usr/discreet/sparks/Furnace3.1v1/F_Kronos.spark_x86_64.setup"
    w.write_loose! "BeginSetupCtrls"
    w.write_loose! "EndSetupCtrls"
    w << "SPARK_PUP 1"
    w << "SPARK_FLOAT 50"
    w << "SPARK_FLOAT 1"
    w << "SPARK_CHANNEL 8"
    w.channel("Frame") do | c |
      export_timing_channel(c, &Proc.new)
    end
    
  end
end