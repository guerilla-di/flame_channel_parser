require "test/unit"
require File.dirname(__FILE__) + "/../lib/flame_channel_parser"
  D = 0.001
class TestFlameChannelParser < Test::Unit::TestCase

  def tabulate(enum)
    STDERR.flush
    enum.each{|tuple| STDERR.puts("%05d %04f" % tuple) }
  end
  
  def tabulate_compare(enum)
    STDERR.flush
    a, b, delta = 
    enum.each do |tuple| 
      f, a, b = tuple
      delta = a - b
      if delta.abs > D
        STDERR.puts("Deviation at %d -> expected %04f and got %04f, delta %04f" %  [f, a, b, delta])
        STDERR.flush
      end
    end
  end
  
  def test_channel_with_constants
    constants = FlameChannelParser.new.parse(DATA).find{|c| c.name == "constants"}
    interp = FlameInterpolator.new(constants)
    puts interp.segments.inspect
    
    values = {}
    
    values = (-5..116).map{|f| [f, interp.sample_at(f)] }
    #tabulate(values)
    
    
    
  end
  
  def test_whole_thing
    channels_in_action = FlameChannelParser.new.parse(File.open("./snaps/FLEM_curves_example.action"))
    channels_in_action.reject!{|c| c.length < 4 }
    
    reference = channels_in_action.find{|c| c.name == "position/x" }
    sampled = channels_in_action.find{|c| c.name == "position/y" }
    ref_i, sample_i = [reference, sampled].map{|c| FlameInterpolator.new(c) }
    
    value_tuples = (1..200).map do |f|  
      [f, ref_i.sample_at(f), sample_i.sample_at(f)]
    end
    
    tabulate_compare(value_tuples)
  end
end

__END__
Channel constants
	Extrapolation constant
	Value 770.41
	Size 4
	KeyVersion 1
	Key 0
		Frame 1
		Value 770.41
		Interpolation constant
		End
	Key 1
		Frame 44
		Value 858.177
		Interpolation constant
		RightSlope 2.31503
		LeftSlope 2.31503
		End
	Key 2
		Frame 74
		Value 939.407
		Interpolation constant
		RightSlope 2.24201
		LeftSlope 2.24201
		End
	Key 3
		Frame 115
		Value 1017.36
		Interpolation constant
		End
	Colour 50 50 50 
	End