require "forwardable"

module FlameChannelParser
  # Represents a channel parsed from the Flame setup. Contains
  # the channel metadata and keyframes (Key objects).
  class Channel
    include Enumerable
    extend Forwardable
    
    attr_reader :node_type, :node_name
    attr_accessor :base_value, :name, :extrapolation
    
    def_delegators :@keys, :empty?, :size, :each, :[]
    alias_method :length, :size
    
    def initialize(io, channel_name, parent_parser, node_type, node_name)
      @keys = []
    
      @node_type = node_type
      @node_name = node_name
      @parser = parent_parser
      @name = channel_name.strip
    
      base_value_matcher = /Value ([\-\d\.]+)/
      keyframe_count_matcher = /Size (\d+)/
      extrapolation_matcher = /Extrapolation (\w+)/
    
      indent = nil
    
      while line = io.gets
      
        unless indent 
          indent = line.scan(/^(\s+)/)[1]
          end_mark = "#{indent}End"
        end
      
        if line =~ keyframe_count_matcher
          $1.to_i.times { @keys.push(extract_key_from(io)) }
        elsif line =~ base_value_matcher && empty?
          self.base_value = $1.to_f
        elsif line =~ extrapolation_matcher
          self.extrapolation = symbolize_literal($1)
        elsif line.strip == end_mark
          break
        end
      end
    
    end
  
    # Returns path to the channel (like axis1/position/x)
    def path
      [@node_name, name].compact.join("/")
    end
  
    # Get an Interpolator for this channel
    def to_interpolator
      FlameChannelParser::Interpolator.new(self)
    end
  
    private
  
    INTERPS = [:constant, :linear, :hermite, :natural, :bezier]
  
    def extract_key_from(io)
      frame = nil
      end_matcher = /End/
    
      key = Key.new
      matchers = @parser.matchers
    
      until io.eof?
        line = io.gets
        if line =~ end_matcher
          return key
        else
          matchers.each do | property, cast_method, pattern  |
              if line =~ pattern
                v = symbolize_literal($1.send(cast_method))
                key.send("#{property}=", v) 
              end
          end
        end
      end
      raise "Did not detect any keyframes!"
    end
    
    LITERALS = %w( linear constant natural hermite cubic bezier cycle revcycle )
    
    def symbolize_literal(v)
      LITERALS.include?(v) ? v.to_sym : v
    end
    
  end
end