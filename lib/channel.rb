require "forwardable"

module FlameChannelParser
  # Represents a channel parsed from the Flame setup. Contains
  # the channel metadata and keyframes (Key objects).
  # Supports the following standard Array methods:
  # :empty?, :size, :each, :[], :push
  class Channel
    include Enumerable
    extend Forwardable
    
    attr_reader :node_type, :node_name
    attr_accessor :base_value, :name, :extrapolation
    
    def_delegators :@keys, :empty?, :size, :each, :[], :push
    alias_method :length, :size
    
    def initialize(io, channel_name, node_type, node_name)
      @keys = []
      @node_type, @node_name, @name = node_type, node_name, channel_name.strip
    end
    
    # Returns path to the channel (like axis1/position/x)
    def path
      [@node_name, name].compact.join("/")
    end
    
    # Get an Interpolator for this channel
    def to_interpolator
      FlameChannelParser::Interpolator.new(self)
    end
  end
end