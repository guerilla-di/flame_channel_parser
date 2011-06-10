require "delegate"

module FlameChannelParser
  VERSION = '2.0.0'
  
  # Parse a Flame setup into an array of ChannelBlock objects
  def self.parse(io)
    Parser.new.parse(io)
  end
end

%w(
  key channel parser_2011 segments interpolator extractor
).each {|f| require File.expand_path(File.dirname(__FILE__) + "/" + f ) }
