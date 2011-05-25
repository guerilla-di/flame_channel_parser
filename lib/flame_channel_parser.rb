require "delegate"

module FlameChannelParser
  VERSION = '1.3.0'
  
  # Parse a Flame setup into an array of ChannelBlock objects
  def self.parse(io)
    parser_class = detect_parser_class_from(io)
    parser_class.new.parse(io)
  end
  
  private
  
  def self.detect_parser_class_from(io)
    # Scan the IO
    until io.eof?
      str = io.gets
      if str =~ /RHandleX/ # Flame 2012, use that parser
        io.rewind
        return Parser2012
      end
    end
    
    io.rewind
    Parser2011
  end
end

require File.expand_path(File.dirname(__FILE__)) + "/parser_2011"
require File.expand_path(File.dirname(__FILE__)) + "/parser_2012"
require File.expand_path(File.dirname(__FILE__)) + "/segments"
require File.expand_path(File.dirname(__FILE__)) + "/interpolator"
require File.expand_path(File.dirname(__FILE__)) + "/extractor"
