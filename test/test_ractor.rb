require "helper"

class TestRactor < Test::Unit::TestCase
  def test_parses_interpolates_and_builds_inside_a_ractor
    omit "Needs Ruby 4.0+ Ractors" unless defined?(Ractor) && Ractor.method_defined?(:value)

    path = File.dirname(__FILE__) + "/snaps/FLEM_curves_example.action"
    expected = run_conversion(path)

    experimental_warnings, Warning[:experimental] = Warning[:experimental], false
    begin
      from_ractor = Ractor.new(path) { |p| TestRactor.new("ractor").run_conversion(p) }.value
      assert_equal expected, from_ractor
    ensure
      Warning[:experimental] = experimental_warnings
    end
  end

  def run_conversion(path)
    channels = File.open(path, "rb") { |f| FlameChannelParser.parse(f) }
    values = channels.reject(&:empty?).map do |channel|
      interpolator = FlameChannelParser::Interpolator.new(channel)
      (1..20).map { |frame| interpolator.sample_at(frame) }
    end

    out = StringIO.new
    FlameChannelParser::Builder.new(out).write_block!("Channel", "foo") { |b| b.some_value 1.0 }
    [values, out.string]
  end
end
