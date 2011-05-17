require "delegate"

module FlameChannelParser
  VERSION = '1.1.0'
  
  # Parse a Flame setup into an array of ChannelBlock objects
  def self.parse(io)
    # Scan the IO
    parser_class = Parser2011
    until io.eof?
      str = io.gets
      if str =~ /RHandleX/ # Flame 2012, use that parser
        parser_class = Parser2012
        break
      end
    end
    io.rewind
    parser_class.new.parse(io)
  end
end

require File.dirname(__FILE__) + "/parser_2011"
require File.dirname(__FILE__) + "/parser_2012"
require File.dirname(__FILE__) + "/interpolator"
