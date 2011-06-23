# Extracts and bakes a specific animation channel to a given buffer, one string per frame
class FlameChannelParser::Extractor
  
  DEFAULT_CHANNEL_TO_EXTRACT = "Timing/Timing"
  
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
  # The output will look like this:
  #
  #   1  123.456
  #   2  124.567
  def self.extract(path, options = {})
    new.extract(path, options)
  end
  
  def extract(path, options)
    options = DEFAULTS.merge(options)
    File.open(path) do |f|
      
      # Then parse
      channels = FlameChannelParser.parse(f)
      selected_channel = find_channel_in(channels, options[:channel])
      interpolator = FlameChannelParser::Interpolator.new(selected_channel)
      
      # Configure the range
      configure_start_and_end_frame(f, options, interpolator)
      write_channel(interpolator, options[:destination], options[:start_frame], options[:end_frame])
    end
  end
  
  private
  
  DEFAULTS = {:destination => $stdout, :start_frame => 1, :end_frame => nil, :channel => DEFAULT_CHANNEL_TO_EXTRACT, :on_curve_limits => false }
  SETUP_END_FRAME_PATTERN = /(MaxFrames|Frames)(\s+)(\d+)/
  SETUP_START_FRAME_PATTERN = /(MinFrame)(\s+)(\d+)/
  
  def configure_start_and_end_frame(f, options, interpolator)
    # If the settings specify last and first frame...
    if options[:on_curve_limits]
      options[:start_frame] = interpolator.first_defined_frame
      options[:end_frame] = interpolator.last_defined_frame
      unless (options[:start_frame] && options[:end_frame])
        raise NoKeyframesError, "This channel probably has no animation so there " + 
          "is no way to automatically tell how many keyframes it has. " +
          "Please set the start and end frame explicitly."
      end
    else # Detect from the setup itself (the default)
      # First try to detect start and end frames from the known flags
      f.rewind
      detected_start, detected_end = detect_start_and_end_frame_in_io(f)
      options[:start_frame] = (detected_start || 1)
      options[:end_frame] = detected_end
    end
  end
  
  
  def detect_start_and_end_frame_in_io(io)
    cur_offset, s, e = io.pos, nil, nil
    io.rewind
    while line = io.gets
      if (elements = line.scan(SETUP_START_FRAME_PATTERN)).any? 
        s = elements.flatten[-1].to_i
      elsif (elements = line.scan(SETUP_END_FRAME_PATTERN)).any? 
        e = elements.flatten[-1].to_i
        return [s, e]
      end
    end
  end
  
  def find_channel_in(channels, channel_path)
    selected_channel = channels.find{|c| channel_path == c.path }
    unless selected_channel
      message = "Channel #{channel_path.inspect} not found in this setup (set the channel with the --channel option). Found other channels though:" 
      message << "\n"
      message += channels.map{|c| "\t%s\n" % c.path }.join
      raise ChannelNotFoundError, message
    end
    selected_channel
  end
  
  def write_channel(interpolator, to_io, from_frame_i, to_frame_i)
    
    raise EmptySegmentError, "The segment you are trying to bake is too small (it has nothing in it)" if to_frame_i - from_frame_i < 1
    
    if (to_frame_i - from_frame_i) == 1
      $stderr.puts "WARNING: You are extracting one animation frame. Check the length of your setup, or set the range manually"
    end
    
    (from_frame_i..to_frame_i).each do | frame |
      line = "%d\t%.5f\n" % [frame, interpolator.sample_at(frame)]
      to_io << line
    end
  end
  
end