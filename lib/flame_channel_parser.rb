require "delegate"
require "interpolator"

class FlameChannelParser
  VERSION = '1.0.0'
  
  class Key
    attr_accessor :frame, :value, :interpolation, :extrapolation, :left_slope, :right_slope
    alias_method :to_s, :inspect
  end
  
  class ChannelBlock < DelegateClass(Array)
    attr_accessor :base_value
    attr_accessor :name
    def initialize(io, channel_name)
      super([])
      
      @name = channel_name.strip

      base_value_matcher = /Value ([\-\d\.]+)/
      keyframe_count_matcher = /Size (\d+)/
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
        elsif line.strip == end_mark
          break
        end
      end
      
    end
    
    MATCHERS  = [
      [:frame, :to_i,  /Frame ([\-\d\.]+)/],
      [:value, :to_f,  /Value ([\-\d\.]+)/],
      [:left_slope, :to_f, /LeftSlope ([\-\d\.]+)/],
      [:right_slope, :to_f, /RightSlope ([\-\d\.]+)/],
      [:interpolation, :to_s, /Interpolation (\w+)/],
      [:extrapolation, :to_s, /Extrapolation (\w+)/],
    ].freeze
    
    INTERPS = [:constant, :linear, :hermite, :natural, ]
    def extract_key_from(io)
      frame = nil
      end_matcher = /End/
      
      key = Key.new
      
      until io.eof?
        line = io.gets
        if line =~ end_matcher
          return key
        else
          MATCHERS.each do | property, cast_method, pattern  |
              if line =~ pattern
                v = symbolize_literal($1.send(cast_method))
                key.send("#{property}=", v) 
              end
          end
        end
      end
      raise "Did not detect any keyframes!"
    end
    
    LITERALS = %w( linear constant natural hermite)
    
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
        report_progress("Extracting channel #{$1}")
        channels << ChannelBlock.new(io, $1)
      end
    end
    channels
  end
  
  def channel_is_useful?(channel_name)
    true
  end
  
  def report_progress(message)
    # flunk
  end
end