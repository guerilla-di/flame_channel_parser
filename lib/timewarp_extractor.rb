module FlameChannelParser
  class TimewarpExtractor
    
    # Channels that can be the timewarp
    CHANNELS = %( Timing/Timing  Frame )
    
    class X < Extractor
    
      # This one is overridden here since instead of looking for a particular channel we are looking
      # for matches from a list
      def find_channel_in(channels, channel_path)
        # Ignore the passed channels, just override
        detected_channel = channels.find{|c| CHANNELS.include?(c.path) }
        return detected_channel if detected_channel
        raise ChannelNotFoundError, compose_channel_not_found_message(CHANNELS.join(' or '), channels)
      end
      
      FRAMECURVE_FORMAT = "%d\t%.5f\r\n"
      
      # Overridden to force CRLF line breaks as per Framecurve spec
      def write_frame(to_io, frame, value)
        to_io.write(FRAMECURVE_FORMAT % [frame, value])
      end
      
      # Overridden to write a framecurve header
      def write_channel(interpolator, to_io, from_frame_i, to_frame_i)
        to_io.write("# http://framecurve.org/specification-v1.html\r\n")
        to_io.write("# at_frame\t use_frame\r\n")
        super
      end
    end
    
    def extract(file_path, options)
      return X.extract(file_path, options)
    end
  end
end