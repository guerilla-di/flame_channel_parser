require "matrix"

module FlameChannelParser::Segments
  
  # This segment just stays on the value of it's keyframe
  class ConstantSegment
  
    NEG_INF = (-1.0/0.0)
    POS_INF = (1.0/0.0)
    
    attr_reader :start_frame, :end_frame
    
    # Tells whether this segment defines the value of the function at this time T
    def defines?(frame)
      (frame < end_frame) && (frame >= start_frame)
    end
    
    # Returns the value at this time T
    def value_at(frame)
      @v1
    end
    
    def initialize(from_frame, to_frame, value)
      @start_frame = from_frame
      @end_frame = to_frame
    
      @v1 = value
    end
  end
  
  # This segment linearly interpolates
  class LinearSegment < ConstantSegment
  
    def initialize(from_frame, to_frame, value1, value2)
      @vint = (value2 - value1)
      super(from_frame, to_frame, value1)
    end
  
    # Returns the value at this time T
    def value_at(frame)
      on_t_interval = (frame - @start_frame).to_f / (@end_frame - @start_frame)
      @v1 + (on_t_interval * @vint)
    end
  end
  
  # This segment does Hermite interpolation
  # using the Flame algo.
  class HermiteSegment < LinearSegment
  
    # In Ruby matrix columns are arrays, so here we go
    HERMATRIX = Matrix[
      [2,  -3,   0,  1],
      [-2,  3,   0,  0],
      [1,   -2,  1,  0],
      [1,   -1,  0,  0]
    ].transpose
  
    def initialize(from_frame, to_frame, value1, value2, tangent1, tangent2)
    
      @start_frame = from_frame
      @end_frame = to_frame
    
      frame_interval = (@end_frame - @start_frame)
    
      # Default tangents in flame are 0, so when we do nil.to_f this is what we will get
      # CC = {P1, P2, T1, T2}
      p1, p2, t1, t2 = value1, value2, tangent1.to_f * frame_interval, tangent2.to_f * frame_interval
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
  
  # This segment does prepolation of a constant value
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
  
  # This segment does extrapolation using a constant value
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
  
  # This can be used for an anim curve that stays constant all along
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
