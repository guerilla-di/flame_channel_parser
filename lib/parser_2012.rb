require "delegate"
require File.dirname(__FILE__) + "/interpolator"

class FlameChannelParser::Parser2012 < FlameChannelParser::Parser2011

  class ModernKey
    attr_accessor :frame, :value, :r_handle_x, :l_handle_x, :r_handle_y, :l_handle_y, :curve_mode, :curve_order, :break_slope
    alias_method :to_s, :inspect
    
    # Adapter for old interpolation
    def interpolation
      return :constant if @curve_order.to_s == "constant"
      return :hermite if @curve_order.to_s == "cubic" && (@curve_mode.to_s == "hermite" || @curve_mode.to_s == "natural")
      return :bezier if @curve_order.to_s == "cubic" && @curve_mode.to_s == "bezier"
      return :linear if @curve_order.to_s == "linear"
      
      raise "Cannot determine interpolation for #{self.inspect}"
    end
    
    # Compute pre-212 slope which we use for interpolations
    def left_slope
      dy = value - l_handle_y
      dx = l_handle_x - frame
      dy / dx  * -1
    end
    
    # Compute pre-212 slope which we use for interpolations
    def right_slope
      dy = value - r_handle_y
      dx = frame - r_handle_x
      dy / dx
    end
    
    def broken?
      break_slope
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
       [:curve_order, :to_s,  /CurveOrder (\w+)/],
       [:break_slope, :to_s,  /BreakSlope (\w+)/],
     ]
   end
   
  
  def create_key
    ModernKey.new
  end
end