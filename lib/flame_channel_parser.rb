module FlameChannelParser
  VERSION = '4.0.0'
  
  module FramecurveWriters; end
  
  # Parse a Flame setup into an array of Channel objects.
  # If a block is given to the method it will yield Channel
  # objects one by one instead of accumulating them into an array (useful for big setups)
  def self.parse(io)
    if block_given?
      Parser.new.parse(io, &Proc.new)
    else
      Parser.new.parse(io)
    end
  end
end

%w(
  key channel parser segments interpolator extractor timewarp_extractor builder
).each {|f| require File.expand_path(File.dirname(__FILE__) + "/" + f ) }

%w(
  softfx_timewarp batch_timewarp kronos 
).each {|f| require File.expand_path(File.dirname(__FILE__) + "/framecurve_writers/" + f ) }
