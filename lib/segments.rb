require "matrix"

NEG_INF = (-1.0/0.0)
POS_INF = (1.0/0.0)

# This segment just stays on the value of it's keyframe
# TODO: speedup
class ConstantSegment
  attr_reader :start_frame, :end_frame
  
  def defines?(frame)
    (frame < end_frame) && (frame >= start_frame)
  end
  
  def value_at(frame)
    @v1
  end
  
  def initialize(from_frame, to_frame, value)
    @start_frame = from_frame
    @end_frame = to_frame
    
    @v1 = value
  end
end

class LinearSegment < ConstantSegment
  
  def initialize(from_frame, to_frame, value1, value2)
    @vint = (value2 - value1)
    super(from_frame, to_frame, value1)
  end
  
  def value_at(frame)
    on_t_interval = (frame - @start_frame).to_f / (@end_frame - @start_frame)
    @v1 + (on_t_interval * @vint)
  end
end

class HermiteSegment < LinearSegment
  
  # In Ruby matrix columns are arrays, so here we go
  HERMATRIX = Matrix[
    [2,  -3,   0,  1],
    [-2,  3,   0,  0],
    [1,   -2,  1,  0],
    [1,   -1,  0,  0]
  ].transpose
  
  def initialize(from_frame, to_frame, value1, value2, tangent1, tangent2)
    
    # Default tangents in flame are 1
    tangent1 ||= 1
    tangent2 ||= 1
    
    @start_frame = from_frame
    @end_frame = to_frame
    
    frame_interval = (@end_frame - @start_frame)
    
    # CC = {P1, P2, T1, T2}
    p1, p2, t1, t2 = value1, value2, tangent1 * frame_interval, tangent2 * frame_interval
    @hermite = Vector[p1, p2, t1, t2]
  end
  
  # P[s_] = S[s].h.CC where s is 0..1 float interpolant on T (interval)
  def value_at(frame)
    
    # Q[frame_] = P[ ( frame - 149 ) / (time_to - time_from)]
    on_t_interval = (frame - @start_frame).to_f / (@end_frame - @start_frame)
    
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

class ConstantPrepolate < LinearSegment
  def initialize(upto_frame, base_value)
    @value = base_value
    @end_frame = upto_frame
    @start_frame = NEG_INF
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
    @start_frame = from_frame
    @base_value = base_value
    @end_frame = POS_INF
  end
  
  def value_at(frame)
    @base_value
  end
end

class ConstantFunction < ConstantSegment
  
  def defines?(frame)
    true
  end
  
  def initialize(value)
    @value = value
  end
  
  def value_at(frame)
    @value
  end
end

if __FILE__ == $0

  herm = HermiteSegment.new(
    time_from = 149,
    time_to = 200,
    value1 = 258.239,
    value2 = 0,
    tangent1 = -0.0149286,
    tangent2 = -0.302127
  )

  (149..200).each do | f |
    puts herm.value_at(f)
  end
end
