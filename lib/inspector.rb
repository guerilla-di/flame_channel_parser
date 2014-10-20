# Prints out a viewable tree of channel metadata. Useful when you need to inspect comparable setups
# for small differentces in channel ordering and animation.
class FlameChannelParser::Inspector
  def initialize(channels_arr)
    @branches = {}
    channels_arr.each {|c| cluster(c) }
  end
  
  def pretty_print(output = $stdout)
    @out = output
    print_branch(@branches, initial_indent = 0)
  end
  
  private
  
  def puts(string)
    @out.puts(string)
  end
  
  def print_branch(branch, indent)
    branch.each_pair do | k, v|
      if v.is_a?(Hash)
        puts((" " * indent) + k)
        print_branch(v, indent + 1)
      else
        puts((" " * indent) + k + " - " + channel_metadata(v))
      end
    end
  end
  
  def channel_metadata(channel)
    if channel.length > 0
      first_key = channel[0].frame
      last_key = channel[-1].frame
      "animated, %d keys, first at %d last at %d" % [channel.length, first_key, last_key]
    else
      "no animations, value %s" % [channel.base_value]
    end
  end
  
  def cluster(channel)
    branches = @branches
  
    path_parts = channel.name.split('/')
    leaf_name = path_parts.pop
  
    current = branches
    path_parts.each do | path_part |
      current[path_part] ||= {}
      current = current[path_part]
    end
    current[leaf_name] = channel
  end
  
end
