require File.expand_path(File.dirname(__FILE__)) + "/segments"

# Used to interpolate Flame animation curves. Pass a Channel
# object to the interpolator and you can then sample values at arbitrary
# frames
class FlameInterpolator
  attr_reader :segments
  
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
      @segments << ConstantExtrapolate.new(@segments[-1].start_frame, channel[-1].value)
    end
  end
  
  def sample_at(frame)
    segment = @segments.find{|s| s.defines?(frame) }
    segment.value_at(frame)
  end
  
  private
  
  # We need both the preceding and the next key
  def key_to_segment(key, next_key)
    case key.interpolation.to_sym
      when :natural, :hermite, :bezier
        HermiteSegment.new(key.frame, next_key.frame, key.value, next_key.value, key.right_slope, incoming_slope(next_key))
      when :constant
        ConstantSegment.new(key.frame, next_key.frame, key.value)
      else # Linear and safe
        LinearSegment.new(key.frame, next_key.frame, key.value, next_key.value)
    end
  end
  
  def incoming_slope(key)
    key.broken? ? key.left_slope : key.right_slope
  end
  
end

