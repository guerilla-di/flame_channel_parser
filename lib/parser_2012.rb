# This parser is automatically used for 2012 setups
class FlameChannelParser::Parser2012 < FlameChannelParser::Parser2011
  
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
end