require "helper"


class TestKey < Test::Unit::TestCase
  D = 0.001
  def test_default_values
    k = FlameChannelParser::Key.new
    assert_in_delta 1.0, k.frame, D
    assert_in_delta 0.0, k.value, D
    assert_equal :constant, k.interpolation
    assert_equal false, k.has_2012_tangents?
    
    assert_nil k.l_handle_x 
    assert_nil k.l_handle_y 
    assert_nil k.r_handle_y 
    assert_nil k.r_handle_x 
  end
  
  def test_constant_curve_mode_translated_to_interpolation
    k = FlameChannelParser::Key.new
    k.curve_mode = :constant
    assert_equal :constant, k.interpolation
  end

  def test_hermite_curve_mode_translated_to_interpolation
    k = FlameChannelParser::Key.new
    assign_tangents_to(k)
    
    k.curve_order = :cubic
    k.curve_mode = :hermite
    assert_equal :hermite, k.interpolation
  end

  def test_natural_curve_mode_translated_to_interpolation
    k = FlameChannelParser::Key.new
    assign_tangents_to(k)
    
    k.curve_order = :cubic
    k.curve_mode = :natural
    assert_equal :hermite, k.interpolation
  end
  
  def test_bezier_curve_mode
    k = FlameChannelParser::Key.new
    assign_tangents_to(k)
    
    k.curve_order = :cubic
    k.curve_mode = :bezier
    assert_equal :bezier, k.interpolation
  end
  
  def test_tangent_computed_from_right_handle
    k = FlameChannelParser::Key.new
    k.frame = 123
    k.value = 123
    
    k.l_handle_x = 120
    k.l_handle_y = 110
    k.r_handle_x = 124
    k.r_handle_y = 145
    
    assert_in_delta 22, k.right_slope, D
    assert_in_delta 22, k.left_slope, D
  end
  
  def test_tangent_computed_from_right_handle_with_broken_slope
    k = FlameChannelParser::Key.new
    k.frame = 123
    k.value = 123
    k.break_slope = true
    
    k.l_handle_x = 120
    k.l_handle_y = 110
    k.r_handle_x = 124
    k.r_handle_y = 145
    
    assert_in_delta 22, k.right_slope, D
    assert_in_delta 4.333, k.left_slope, D
  end
  
  private
  
  def assign_tangents_to(to_key)
    to_key.l_handle_x = to_key.l_handle_y = to_key.r_handle_x = to_key.r_handle_y = 1
  end
end