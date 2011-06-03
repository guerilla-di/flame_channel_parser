# Extracts and bakes a specific animation channel
class FlameChannelParser::Extractor
  
  DEFAULT_CHANNEL_TO_EXTRACT = "Timing/Timing"
  DEFAULTS = {:destination => $stdout, :start_frame => nil, :end_frame => nil, :channel => DEFAULT_CHANNEL_TO_EXTRACT }
  
  # Raised when a channel is not found in the setup file
  class ChannelNotFoundError < RuntimeError; end
  
  # Raised when you try to autodetect the length of a channel that has no keyframes
  class NoKeyframesError < RuntimeError; end
  
  # Pass the path to Flame setup here and you will get the timewarp curve on STDOUT
  def self.extract(path, options = {})
    options = DEFAULTS.merge(options)
    File.open(path) do | f |
      channels = FlameChannelParser.parse(f)
      selected_channel = channels.find{|c| options[:channel] == c.path }
      unless selected_channel
        message = "Channel #{options[:channel]} not found in this setup (set the channel with the --channel option). Found other channels though:" 
        message << "\n"
        message += channels.map{|c| "\t%s\n" % c.path }.join
        raise ChannelNotFoundError, message
      end
      
      write_channel(selected_channel, options[:destination], options[:start_frame], options[:end_frame])
    end
  end
  
  private
  
  def self.write_channel(channel, to_io, start_frame, end_frame)
    interpolator = FlameChannelParser::Interpolator.new(channel)
    
    from_frame = start_frame || interpolator.first_defined_frame
    to_frame =  end_frame || interpolator.last_defined_frame
    unless (from_frame && to_frame)
      raise NoKeyframesError, "This channel probably has no animation so there is no way to automatically tell how many keyframes it has. " +
        "Please set the start and end frame explicitly."
    end
    
    (from_frame..to_frame).each do | frame |
      to_io.puts("%d\t%.5f" % [frame, interpolator.sample_at(frame)])
    end
  end
  
end