require "matrix"

NEG_INF = (-1.0/0.0)
POS_INF = (1.0/0.0)

class LinearSegment
  attr_reader :from_f, :to_f
  
  def defines?(frame)
    (frame < to_f) && (frame >= from_f)
  end
  
  def initialize(from_frame, to_frame, value1, value2)
    @from_f = from_frame
    @to_f = to_frame
    @v1 = value1
    @vint = (value2 - value1)
  end
  
  def frame_interval
    @to_f - @from_f
  end
  
  def value_at(frame)
    on_t_interval = (frame - @from_f).to_f / (@to_f - @from_f)
    @v1 + (on_t_interval * @vint)
  end
end

class HermiteSegment < LinearSegment
  
  HERMATRIX = Matrix[
    [2,  -2,  1,  1],
    [-3,  3, -2, -1],
    [0,   0,  1,  0],
    [1,   0,  0,  0]
  ]
  
  def initialize(from_frame, to_frame, value1, value2, tangent1, tangent2)
    super(from_frame, to_frame, value1, value2)
    
    # CC = {P1, P2, T1, T2}
    p1, p2, t1, t2 = value1, value2, tangent1 * frame_interval, tangent2 * frame_interval
    @hermite = Vector[p1, p2, t1, t2]
  end
  
  # P[s_] = S[s].h.CC where s is 0..1 float interpolant on T (interval)
  def value_at(frame)
    
    # Q[frame_] = P[ ( frame - 149 ) / (time_to - time_from)]
    on_t_interval = (frame - @from_f).to_f / frame_interval.to_f
    
    # S[s_] = {s^3, s^2, s^1, s^0}
    multipliers_vec = Vector[on_t_interval ** 3,  on_t_interval ** 2, on_t_interval ** 1, on_t_interval ** 0]
    
    # P[s_] = S[s].h.CC --> Kaboom!
    interpolated_scalar = dot_product(HERMATRIX * @hermite, multipliers_vec)
  end
  
  private
  
  def dot_product(one, two)
    sum = 0.0
    (0...one.size).each { |i|  sum += one[i] * two[i] }
    sum
  end
  
end

# TODO: Represents a segment with Natural interp
class NaturalSegment  < HermiteSegment
end

# This segment just stays on the value of it's keyframe
# TODO: speedup
class ConstantSegment < LinearSegment
  def initialize(from_frame, to_frame, value)
    super(from_frame, to_frame, value, value)
  end
end

class ConstantPrepolate < LinearSegment
  def initialize(upto_frame, base_value)
    @value = base_value
    @to_f = upto_frame
    @from_f = NEG_INF
  end
  
  def value_at(frame)
    @value
  end
  
  private
    def frame_increment
      23.0
    end
end

class ConstantExtrapolate < LinearSegment
  def initialize(from_frame, base_value)
    @from_f = from_frame
    @base_value = base_value
    @to_f = POS_INF
  end
  
  def value_at(frame)
    @base_value
  end
end

class ConstantFunction < LinearSegment
  def initialize(value)
    @value = value
    @from_f = NEG_INF
    @to_f = NEG_INF
  end
  
  def value_at(frame)
    @value
  end
end

# Represents the whole curve
class CompoundSegment
  def initialize(*contained_segments)
    @segments = contained_segments.flatten
  end
  
  def value_at(frame)
    if frame <= @segments[0].from_f || frame < @segments[0].to_f
      @segments[0].value_at(frame)
    elsif frame >= @segments[-1].to_f
      @segments[-1].value_at(frame)
    else
      on_segment = @segments.find{|s| (s.from_f <= frame) && (s.to_f >= frame) }
      on_segment.value_at(frame)
    end
  end
end

if __FILE__ == $0

  line = LinearSegment.new(
    time_from = 1,
    time_to = 149,
    value1 = 13,
    value2 = 258.239
  )

  herm = HermiteSegment.new(
    time_from = 149,
    time_to = 200,
    value1 = 258.239,
    value2 = 0,
    tangent1 = -0.0149286,
    tangent2 = -0.302127
  )

  curve  = CompoundSegment.new(line, herm)

  (1..200).each do | f |
    puts curve.value_at(f)
  end
end
