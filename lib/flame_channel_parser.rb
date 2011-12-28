module FlameChannelParser
  VERSION = '4.0.0'
  
  module FramecurveWriters; end
  
  # Parse a Flame setup into an array of Channel objects.
  # If a block is given to the method it will yield Channel
  # objects one by one instead of accumulating them into an array (useful for big setups)
  def self.parse(io)
    c = get_parser_class(io)
    if block_given?
      c.new.parse(io, &Proc.new)
    else
      c.new.parse(io)
    end
  end
  
  private
  
  # Returns the XML parser class for XML setups
  def self.get_parser_class(for_io)
    token = '<Setup>'
    current = for_io.pos
    parser_class = if for_io.read(token.size) == token
      XMLParser
    else
      Parser
    end
    for_io.seek(current)
    return parser_class
  end
end

%w(
  key channel parser segments interpolator extractor timewarp_extractor builder xml_parser
).each {|f| require File.expand_path(File.dirname(__FILE__) + "/" + f ) }

%w(
  softfx_timewarp batch_timewarp kronos 
).each {|f| require File.expand_path(File.dirname(__FILE__) + "/framecurve_writers/" + f ) }
