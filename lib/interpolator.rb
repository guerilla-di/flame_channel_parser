require File.expand_path(File.dirname(__FILE__)) + "/segments"

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
      @segments << ConstantExtrapolate.new(@segments[-1].to_f, channel[-1].value)
    end
  end
  
  def sample_at(frame)
    segment = @segments.find{|s| s.defines?(frame) }
    segment.value_at(frame)
  end
  
  private
  
  # We need both the preceding and the next key
  def key_to_segment(key, next_key)
    case key.interpolation
      when :natural
        NaturalSegment.new(key.frame, next_key.frame, key.value, next_key.value, key.left_slope, next_key.right_slope)
      when :hermite
        HermiteSegment.new(key.frame, next_key.frame, key.value, next_key.value, key.left_slope, next_key.right_slope)
      when :linear
        LinearSegment.new(key.frame, next_key.frame, key.value, next_key.value)
      when :constant
        ConstantSegment.new(key.frame, next_key.frame, key.value)
      else
        raise "Unknown segment type #{key.interpolation}"
    end
  end
  
  
end

