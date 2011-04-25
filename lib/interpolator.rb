class FlameInterpolator
  
  def initialize(chan)
    @chan = chan
  end
  
  def bake(from_frame, upto__and_including_frame)
    # Will return an array of values
    (from_frame..upto__and_including_frame).map do | at_f |
      sample_at(at_f)
    end
  end
  
  def sample_at(frame)
    left_f, right_f = find_siblings(frame)
    if left_f && right_f && (left_f == right_f) # On the value 
      left_f.value
    elsif !left_f && right_f
      extrapolate_based_on(frame, right_f)
    elsif left_f && !right_f
      extrapolate_based_on(frame, left_f)
    elsif (left_f && right_f)
      interpolate_between(left_f, right_f, frame)
    else
      raise "No frames to either side of #{frame}, giving up"
    end
  end
  
  private
  
  def interpolate_between(left_f, right_f, frame)
    if left_f.interpolation == :constant
      left_f.value
    elsif left_f.interpolation == :linear
      y_int = (right_f.value - left_f.value)
      x_int = (right_f.frame - left_f.frame)
      x_off = frame - left_f.frame
      (x_off.to_f / x_int.to_f) * y_int # just lerp
    elsif left_f.interpolation == :hermite
      interp_hermite(left_f, right_f, frame)
    elsif left_f.interpolation == :natural
      raise "Fail. Julik needs mathz for natural."
    end
  end

  def interp_hermite(left_f, right_f, frame)
    puts [left_f, right_f, frame].inspect
    
    raise "Fail. Julik needs mathz for hermite."
  end
  
  def find_siblings(of_frame)
    left, right = nil, nil
    right = @chan.find{|k| k.frame >= of_frame }
    left = @chan.reverse.find{|k| k.frame <= of_frame }
    [left, right]
  end
  
  def extrapolate_based_on(frame, base_f)
    if (base_f.extrapolation == :constant)
      base_f.value
    elsif (base_f.extrapolation == :linear)
      frame_dist = base_f.frame
      coeff = base_f.left_slope # Pitfall
      base_f.value - ((frame - base_f.frame) * coeff)
    elsif !base_f.extrapolation # Flame does not write extrap when interp is present - use the interpolation value instead
      dupe = base_f.dup
      dupe.extrapolation = (base_f.interpolation == :constant) ? :constant : :linear
      extrapolate_based_on(frame, dupe)
    end
  end
  
end