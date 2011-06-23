module FlameChannelParser
  VERSION = '2.0.1'
  
  # Parse a Flame setup into an array of Channel
  def self.parse(io)
    Parser.new.parse(io)
  end
end

%w(
  key channel parser segments interpolator extractor
).each {|f| require File.expand_path(File.dirname(__FILE__) + "/" + f ) }
