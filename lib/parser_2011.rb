require "forwardable"

# Basic parser used for setups from versions up to 2011
module FlameChannelParser
  class Parser2011
    # Parses the setup passed in the IO
    def parse(io)
      channels = []
      node_name, node_type = nil, nil
    
      until io.eof?
        line = io.gets
        if line =~ NODE_TYPE_MATCHER
          node_type = $1
        elsif line =~ NODE_NAME_MATCHER
          node_name = $1
        elsif line =~ CHANNEL_MATCHER && channel_is_useful?($1)
          channels << Channel.new(io, $1, self, node_type, node_name)
        end
      end
      channels
    end
  
    # Override this method to skip some channels, this will speedup
    # your code alot
    def channel_is_useful?(channel_name)
      true
    end
    
    # Defines a number of regular expression matchers applied to the file as it is being parsed
    def matchers #:nodoc:
      [
        [:frame, :to_i,  /Frame ([\-\d\.]+)/],
        [:value, :to_f,  /Value ([\-\d\.]+)/],
        [:left_slope, :to_f, /LeftSlope ([\-\d\.]+)/],
        [:right_slope, :to_f, /RightSlope ([\-\d\.]+)/],
        [:interpolation, :to_s, /Interpolation (\w+)/],
        [:break_slope, :to_s, /BreakSlope (\w+)/]
      ]
    end
    
    CHANNEL_MATCHER = /Channel (.+)\n/
    NODE_TYPE_MATCHER = /Node (\w+)/
    NODE_NAME_MATCHER = /Name (\w+)/
  
  end
end