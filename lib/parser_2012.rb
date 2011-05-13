require "delegate"
require File.dirname(__FILE__) + "/interpolator"

class FlameChannelParser::Parser2012 < FlameChannelParser::Parser2011

  class ModernKey
    attr_accessor :frame, :value, :r_handle_x, :l_handle_x, :r_handle_y, :l_handle_y, :curve_mode, :curve_order, :break_slope
    alias_method :to_s, :inspect
    
    # Adapter for old interpolation
    def interpolation
      curve_order
    end
    
    # Compute oldskool slope
    def left_slope
      dy = value - l_handle_y
      dx = l_handle_x - frame
      dx
    end
    
    # Compute oldskool slope
    def right_slope
      dy = value - r_handle_y
      dx = r_handle_x - frame
      dx
    end
    
    def broken?
      break_slope == "Yes"
    end
    
  end
  
  def matchers
     [
       [:frame, :to_i,  /Frame ([\-\d\.]+)/],
       [:value, :to_f,  /Value ([\-\d\.]+)/],
       [:r_handle_x, :to_f, /RHandleX ([\-\d\.]+)/],
       [:l_handle_x, :to_f, /LHandleX ([\-\d\.]+)/],
       [:r_handle_y, :to_f, /RHandleY ([\-\d\.]+)/],
       [:l_handle_y, :to_f, /LHandleY ([\-\d\.]+)/],
       [:curve_mode, :to_s,  /CurveMode (\w+)/],
       [:curve_order, :to_s,  /CurveMode (\w+)/],
       [:break_slope, :to_s,  /BreakSlope (\w+)/],
     ]
   end
   
  
  def create_key
    ModernKey.new
  end
end