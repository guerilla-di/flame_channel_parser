require "test/unit"
require "flame_channel_parser"

f = File.open(File.dirname(__FILE__) + "/snaps/FLEM_curves_example.action")
channels = FlameChannelParser.new.parse(f)
channels.reject!{|c| c.length < 2}

baked = channels.find{|c| c.name == "position/x" }
File.open("./baked.csv", "w") do | f |
  f.puts("x,y")
  baked.each do | kf |
    f.puts([kf.frame, kf.value].join(","))
  end
end

interp = channels.find{|c| c.name == "position/y" }
File.open("./curve.csv", "w") do | f |
  attrs = [:frame, :value, :interpolation, :extrapolation, :left_slope, :right_slope]
  f.puts(attrs.join(","))
  interp.each do | kf |
    f.puts( attrs.map{|attr| kf.send(attr)}.join(",") )
  end
end