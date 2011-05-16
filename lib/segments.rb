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
      
      @start_frame, @end_frame = from_frame, to_frame
      
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
  
  Point = Struct.new(:x, :y)
  
  class BezierSegment < LinearSegment
    def initialize(from_frame, to_frame, value1, value2, t1x, t1y, t2x, t2y)
      @start_frame, @end_frame = from_frame, to_frame
      
      p1 = Point.new(from_frame, value1)
      tan1 = Point.new(t1x, t1y)
      tan2 = Point.new(t2x, t2y)
      p2 = Point.new(to_frame, value2)
      
      @values = curve4(p1, tan1, tan2, p2)
      puts @values.inspect
    end
    
    def value_at(frame)
      v = @values.find{|v| v[0] == frame }
      raise "No definition at #{frame}" unless v
      v[-1]
    end
    
    private
    
    # Anchor1, Control1, Control2, Anchor2
    def curve4(p1, t1, t2, p2)
        
        x1, y1 = p1.x, p1.y
        x2, y2 = t1.x, t1.y
        x3, y3 = p2.x, p2.y
        x4, y4 = t2.x, t2.y
        
        num_steps = p2.x - p1.x # number of frames
        
        dx1 = x2 - x1
        dy1 = y2 - y1
        dx2 = x3 - x2
        dy2 = y3 - y2
        dx3 = x4 - x3
        dy3 = y4 - y3
        
        subdiv_step  = 1.0 / (num_steps + 1)
        subdiv_step2 = subdiv_step ** 2
        subdiv_step3 = subdiv_step ** 3
        
        pre1 = 3.0 * subdiv_step
        pre2 = 3.0 * subdiv_step2
        pre4 = 6.0 * subdiv_step2
        pre5 = 6.0 * subdiv_step3
        
        tmp1x = x1 - x2 * 2.0 + x3
        tmp1y = y1 - y2 * 2.0 + y3
        
        tmp2x = (x2 - x3)*3.0 - x1 + x4
        tmp2y = (y2 - y3)*3.0 - y1 + y4
        
        fx = x1
        fy = y1
        
        dfx = (x2 - x1)*pre1 + tmp1x*pre2 + tmp2x*subdiv_step3
        dfy = (y2 - y1)*pre1 + tmp1y*pre2 + tmp2y*subdiv_step3
        
        ddfx = tmp1x*pre4 + tmp2x*pre5;
        ddfy = tmp1y*pre4 + tmp2y*pre5;
        
        dddfx = tmp2x*pre5;
        dddfy = tmp2y*pre5;
        
        values = []
        
        num_steps.downto(0) do | num |
            fx   += dfx
            fy   += dfy
            dfx  += ddfx
            dfy  += ddfy
            ddfx += dddfx
            ddfy += dddfy
            values << [fx, fy]
        end
        values.each do | x, y |
          puts "#{x}\t #{y}"
        end
        
        values
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

