require "delegate"

# Basic parser used for setups from versions up to 2011
class FlameChannelParser::Parser2011
  
  # Represents a keyframe
  class Key
    attr_accessor :frame, :value, :interpolation, :extrapolation, :left_slope, :right_slope, :break_slope
    alias_method :to_s, :inspect
    
    # Unless the key is broken? we should just use the right slope
    def left_slope
      return right_slope unless broken?
      @left_slope
    end
    
    # Tells whether the slope of this keyframe is broken (not smooth)
    def broken?
      break_slope
    end
  end
  
  # Defines a number of regular expression matchers applied to the file as it is being parsed
  def matchers
    [
      [:frame, :to_i,  /Frame ([\-\d\.]+)/],
      [:value, :to_f,  /Value ([\-\d\.]+)/],
      [:left_slope, :to_f, /LeftSlope ([\-\d\.]+)/],
      [:right_slope, :to_f, /RightSlope ([\-\d\.]+)/],
      [:interpolation, :to_s, /Interpolation (\w+)/],
      [:extrapolation, :to_s, /Extrapolation (\w+)/],
      [:break_slope, :to_s, /BreakSlope (\w+)/]
    ]
  end
  
  def create_key
    Key.new
  end
  
  # Represents a channel parsed from the Flame setup. Contains
  # the channel metadata and keyframes
  class ChannelBlock < DelegateClass(Array)
    attr_accessor :base_value
    attr_accessor :name
    attr_accessor :extrapolation
    
    def initialize(io, channel_name, parent_parser)
      super([])
      
      @parser = parent_parser
      @name = channel_name.strip
      
      base_value_matcher = /Value ([\-\d\.]+)/
      keyframe_count_matcher = /Size (\d+)/
      extrapolation_matcher = /Extrapolation (\w+)/
      indent = nil
      
      while line = io.gets
        
        unless indent 
          indent = line.scan(/^(\s+)/)[1]
          end_mark = "#{indent}End"
        end
        
        if line =~ keyframe_count_matcher
          $1.to_i.times { push(extract_key_from(io)) }
        elsif line =~ base_value_matcher && empty?
          self.base_value = $1.to_f
        elsif line =~ extrapolation_matcher
          self.extrapolation = symbolize_literal($1)
        elsif line.strip == end_mark
          break
        end
      end
      
    end
    
    # Get an Interpolator from this channel
    def to_interpolator
      FlameChannelParser::Interpolator.new(self)
    end
    
    private
    
    def create_key
      Key.new
    end
    
    INTERPS = [:constant, :linear, :hermite, :natural, :bezier]
    
    def extract_key_from(io)
      frame = nil
      end_matcher = /End/
      
      key = @parser.create_key
      matchers = @parser.matchers
      
      until io.eof?
        line = io.gets
        if line =~ end_matcher
          return key
        else
          matchers.each do | property, cast_method, pattern  |
              if line =~ pattern
                v = symbolize_literal($1.send(cast_method))
                key.send("#{property}=", v) 
              end
          end
        end
      end
      raise "Did not detect any keyframes!"
    end
    
    LITERALS = %w( linear constant natural hermite cubic bezier)
    
    def symbolize_literal(v)
      LITERALS.include?(v) ? v.to_sym : v
    end
    
  end
  
  CHANNEL_MATCHER = /Channel (.+)\n/
  
  def parse(io)
    channels = []
    until io.eof?
      line = io.gets
      if line =~ CHANNEL_MATCHER && channel_is_useful?($1)
        channels << ChannelBlock.new(io, $1, self)
      end
    end
    channels
  end
  
  # Override this method to skip some channels, this will speedup
  # your code alot
  def channel_is_useful?(channel_name)
    true
  end
  
end