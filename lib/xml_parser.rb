require 'rexml/document'
require "rexml/streamlistener"

class FlameChannelParser::XMLParser < FlameChannelParser::Parser
  # Here you can assign a logger proc or a lambda that will be call'ed with progress reports
  attr_accessor :logger_proc
  
  # A SAX-based translation layer
  class XMLToSetup
    include REXML::StreamListener
    
    def initialize(vanilla_setup)
      @dest = vanilla_setup
      @indent = 0
      @in_channel = false
      @path = []
    end
    
    # <KFrames>
    #   <Key Index="0">
    #     <Frame>1.000000</Frame>
    #     <Value>100</Value>
    #     <RHandleX>1.297667</RHandleX>
    #     <RHandleY>100.000000</RHandleY>
    #     <LHandleX>0.750000</LHandleX>
    #     <LHandleY>100.000000</LHandleY>
    #     <CurveMode>hermite</CurveMode>
    #     <CurveOrder>linear</CurveOrder>
    #   </Key>
    # </KFrames>
    def tag_start(element, attributes)
      @path.push(element)
      if element == "Channel"
        channel_name = attributes["Name"]
        @in_channel = true
        # Compose the full channel name
        
        @dest.puts("Channel %s" % channel_name)
      elsif element == "Key"
        @in_key = true
        @dest.puts("\tKey %d" % attributes["Index"].to_i)
      end
    end
    
    def text(text)
      @text = text
    end
    
    def tag_end(element)
      @path.pop
      if element == "Channel"
        @in_channel = false
        @dest.puts("\tEnd")
      end
      
      if element == "Key"
        @in_key = false
        @dest.puts("\t\tEnd")
      end
      
      if @in_key
        @dest.puts("\t\t" + transfo(element) + " " + @text)
      end
      
      if !@in_key && @in_channel
        @dest.puts("\t" + transfo(element) + " " + @text)
      end
    end
    
    def transfo(t)
      t == "Extrap" ? "Extrapolation" : t
    end
  end
  
  # Parses the setup passed in the IO. If a block is given to the method it will yield Channel
  # objects one by one instead of accumulating them into an array (useful for big setups)
  def parse(io)
    # Ok this is gothic BUT needed. What we do is we transform the XML setup into the OLD
    # setup format, after which we run it through the OLD parser all the same.
    # I am almost sure that ADSK does the same.
    t = Tempfile.new("bx")
    REXML::Document.parse_stream(io, XMLToSetup.new(t))
    t.rewind
    if block_given?
      super(t, &Proc.new)
    else
      super(t)
    end
  end
end