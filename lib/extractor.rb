# Extracts and bakes a specific animation channel
class FlameChannelParser::Extractor
  
  DEFAULTS = {:destination => $stdout, :start_frame => nil, :end_frame => nil, :channel => "Timing/Timing" }
  
  # Pass the path to Flame setup here and you will get the timewarp curve on STDOUT
  def extract(path, options = {})
    options = DEFAULTS.merge(options)
    File.open(path) do | f |
      channels = FlameChannelParser.parse(f)
      selected_channel = channels.find{|c| options[:channel] == c.name }
      unless selected_channel
        message = "Channel not #{option[:channel]}found in this setup (set the channel with the --channel option). Found other channels though:" 
        message << "\n"
        message += channels.map{|c| c.name }.join("\n")
        raise message
      end
      
      write_channel(selected_channel, options[:destination], options[:start_frame], options[:end_frame])
    end
  end
  
  private
  
  def write_channel(channel, to_io, start_frame, end_frame)
    interpolator = FlameChannelParser::Interpolator.new(channel)
    
    from_frame = start_frame || interpolator.first_defined_frame
    to_frame =  end_frame || interpolator.last_defined_frame
    
    (from_frame..to_frame).each do | frame |
      to_io.puts("%d\t%.5f" % [frame, interpolator.sample_at(frame)])
    end
  end
  
end