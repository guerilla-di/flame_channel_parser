# A Builder-like class for exporting Flame setups
class FlameChannelParser::Builder #< BasicObject
  INDENT = "\t"
  
  def initialize(io, indent = 0)
    @io, @indent = io, indent
  end
  
  # Writes a block of values delimited by "End" terminators.
  # Will yield a nested Builder objectg which 
  def write_block!(name, value = nil, &blk)
    value.nil? ? write_loose!(name) : write_tuple!(name, value)
    yield(self.class.new(@io, @indent + 1))
    @io.puts(INDENT * (@indent + 1) + "End")
  end
  
  # Write an unterminated block of values
  def write_unterminated_block!(name, value = nil, &blk)
    value.nil? ? write_loose!(name) : write_tuple!(name, value)
    yield(self.class.new(@io, @indent + 1))
  end
  
  # Write a tuple of "Parameter Value", like "Frame 13"
  def write_tuple!(key, value)
    @io.puts("%s%s %s" % [INDENT * @indent, __camelize(key), __flameize(value)])
  end
  
  # Write a number of linebreaks
  def write_loose!(value)
    @io.puts("%s%s" % [INDENT * @indent, __camelize(value)])
  end
  
  # Write a number of linebreaks
  def linebreak!(how_many = 1)
    @io.write("\n" * how_many)
  end
  
  # Write a color hash with the right order of values
  def color_hash!(name, red, green, blue)
    write_unterminated_block!(name) do | b |
      b.red(red)
      b.green(green)
      b.blue(blue)
    end
  end
  
  # Append the text passed to the setup. The appended
  # lines will be prepended by the indent of the current builder
  def <<(some_verbatim_string)
    some_verbatim_string.split("\n").each do | line |
      @io.puts(["\t" * @indent, line].join)
    end
  end
  
  private
  
  def method_missing(meth, arg = nil)
    if block_given?
      write_block!(meth, arg) {|c| yield(c) }
    else
      if arg.nil?
        write_loose!(meth)
      else
        write_tuple!(meth, arg)
      end
    end
  end
  
  def __camelize(s)
    @@camelizations ||= {}
    @@camelizations[s] ||= s.to_s.gsub(/(^|_)(.)/) { $2.upcase }
  end
  
  def __flameize(v)
    case v
      when Float
        "%.3f" % v
      when TrueClass
        "yes"
      when FalseClass
        "no"
      else
        v.to_s
    end
  end
end