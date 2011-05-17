require File.expand_path(File.dirname(__FILE__)) + "/segments"

# Used to sample Flame animation curves. Pass a Channel
# object to the interpolator and you can then sample values at arbitrary
# frames.
#
#   i = Interpolator.new(parsed_channel)
#   i.value_at(245.5) # => will interpolate and return the value
#
class FlameChannelParser::Interpolator
  include FlameChannelParser::Segments
  
  attr_reader :segments
  
  NEG_INF = (-1.0/0.0)
  POS_INF = (1.0/0.0)
  
  # The constructor will accept a ChannelBlock object and convert it internally to a number of
  # segments from which samples can be made
  def initialize(channel)
    
    # Edge case - channel has no anim at all
    if (channel.length == 0)
      @segments = [ConstantFunction.new(channel.base_value)]
    elsif (channel.length == 1)
      @segments = [ConstantFunction.new(channel[0].value)]
    else
      @segments = []
      
      # TODO: extrapolation is set for the whole channel, both begin and end.
      # First the prepolating segment
      @segments << ConstantPrepolate.new(channel[0].frame, channel[0].value)
      
      # The last key defines extrapolation for the rest of the curve...
      channel[0..-2].each_with_index do | key, index |
        @segments << key_to_segment(key, channel[index + 1])
      end
      
      # so we just output it separately
      @segments << ConstantExtrapolate.new(@segments[-1].end_frame, channel[-1].value)
    end
  end
  
  # Sample the value of the animation curve at this frame
  def sample_at(frame)
    segment = @segments.find{|s| s.defines?(frame) }
    segment.value_at(frame)
  end
  
  # Returns the first frame number that is concretely defined as a keyframe
  # after the prepolation ends
  def first_defined_frame
    first_f = @segments[0].end_frame
    return 1 if first_f == NEG_INF
    return first_f
  end
  
  # Returns the last frame number that is concretely defined as a keyframe
  # before the extrapolation starts
  def last_defined_frame
    last_f = @segments[-1].start_frame
    return 100 if last_f == POS_INF
    return last_f
  end
  
  private
  
  # We need both the preceding and the next key
  def key_to_segment(key, next_key)
    case key.interpolation
      when :bezier
        BezierSegment.new(key.frame, next_key.frame,
          key.value, next_key.value, 
          key.r_handle_x, 
          key.r_handle_y, 
          next_key.l_handle_x, next_key.l_handle_y)
      when :natural, :hermite
        HermiteSegment.new(key.frame, next_key.frame, key.value, next_key.value, key.right_slope, incoming_slope(next_key))
      when :constant
        ConstantSegment.new(key.frame, next_key.frame, key.value)
      else # Linear and safe
        LinearSegment.new(key.frame, next_key.frame, key.value, next_key.value)
    end
  end
  
  # Flame uses the right slope for both left and right unless the BrokenSlope tag is set
  def incoming_slope(key)
    key.broken? ? key.left_slope : key.right_slope
  end
  
end

