require "delegate"

module FlameChannelParser
  VERSION = '2.0.0'
  
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

%w(
  key channel parser_2011 parser_2012 segments interpolator extractor
).each {|f| require File.expand_path(File.dirname(__FILE__) + "/" + f ) }
