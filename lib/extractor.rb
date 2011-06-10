# Extracts and bakes a specific animation channel
class FlameChannelParser::Extractor
  
  DEFAULT_CHANNEL_TO_EXTRACT = "Timing/Timing"
  DEFAULTS = {:destination => $stdout, :start_frame => nil, :end_frame => nil, :channel => DEFAULT_CHANNEL_TO_EXTRACT }
  
  # Raised when a channel is not found in the setup file
  class ChannelNotFoundError < RuntimeError; end
  
  # Raised when you try to autodetect the length of a channel that has no keyframes
  class NoKeyframesError < RuntimeError; end
  
  # Raised when you try to bake 0 or negative amount of frames
  class EmptySegmentError < RuntimeError; end
  
  # Pass the path to Flame setup here and you will get the animation curve on the object passed in
  # the :destionation option (defaults to STDOUT). The following options are accepted:
  #
  #  :destination - The object to write the output to, anything that responds to shovel (<<) will do
  #  :start_frame - From which frame the curve should be baked. Will default to the first keyframe of the curve
  #  :end_frame - Upto which frame to bake. Will default to the last keyframe of the curve
  #  :channel - Name of the channel to extract from the setup. Defaults to "Timing/Timing" (timewarp frame)
  #
  # Note that start_frame and end_frame will be converted to integers.
  def self.extract(path, options = {})
    options = DEFAULTS.merge(options)
    File.open(path) do |f|
      channels = FlameChannelParser.parse(f)
      selected_channel = find_channel_in(channels, options[:channel])
      interpolator = FlameChannelParser::Interpolator.new(selected_channel)
      write_channel(interpolator, options[:destination], options[:start_frame], options[:end_frame])
    end
  end
  
  private
  
  def self.find_channel_in(channels, channel_path)
    selected_channel = channels.find{|c| channel_path == c.path }
    unless selected_channel
      message = "Channel #{channel_path.inspect} not found in this setup (set the channel with the --channel option). Found other channels though:" 
      message << "\n"
      message += channels.map{|c| "\t%s\n" % c.path }.join
      raise ChannelNotFoundError, message
    end
    selected_channel
  end

  def self.write_channel(interpolator, to_io, start_frame, end_frame)
    
    from_frame = start_frame || interpolator.first_defined_frame
    to_frame =  end_frame || interpolator.last_defined_frame
    
    unless (from_frame && to_frame)
      raise NoKeyframesError, "This channel probably has no animation so there is no way to automatically tell how many keyframes it has. " +
        "Please set the start and end frame explicitly."
    end
    
    raise EmptySegmentError, "The segment you are trying to bake is too small (it has nothing in it)" if to_frame - from_frame < 1
    
    from_frame_i = from_frame.to_f.floor
    to_frame_i = to_frame.to_f.ceil
    
    (from_frame_i..to_frame_i).each do | frame |
      line = "%d\t%.5f\n" % [frame, interpolator.sample_at(frame)]
      to_io << line
    end
  end
  
end