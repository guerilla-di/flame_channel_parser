require "./helper"


include FlameChannelParser::Segments

class TestConstantFunction < Test::Unit::TestCase
  D = 0.001
  def test_segment
    seg = ConstantFunction.new(123.4)
    assert seg.defines?(-1), "The segment should define this frame"
    assert seg.defines?(4567), "The segment should define this frame"
    assert_equal 123.4, seg.value_at(123), "This is the segment's constant value"
  end
end


class TestConstantSegment < Test::Unit::TestCase
  D = 0.001
  def test_segment
    seg = ConstantSegment.new(12, 25, 2.5)
    
    assert !seg.defines?(11), "This frame is outside the segment"
    assert !seg.defines?(26), "This frame is outside the segment"
    assert seg.defines?(12), "Frame 12 defined"
    assert seg.defines?(24), "Frame 24 defined"
    
    assert_equal 2.5, seg.value_at(11)
    assert_equal 2.5, seg.value_at(14)
    assert_equal 2.5, seg.value_at(26)
  end
end

class TestBezierSegment < Test::Unit::TestCase
  D = 0.001
  def test_segment
    seg = BezierSegment.new(
      frame_from = 117,
      frame_to = 149, 
      value_from = 1.23907006, 
      value_to = 258.239014, 
      handle_left_x = 117.25, 
      handle_left_y = 4.76008224, 
      handle_right_x = 138.333328, 
      handle_right_y = 258.398254
    )
    assert seg.defines?(117)
    assert !seg.defines?(149)
    assert !seg.defines?(151)
    assert !seg.defines?(116)
    
    assert_in_delta 1.23907006, seg.value_at(25), D
    assert_in_delta 24.7679917574603, seg.value_at(119), D
  end
end

class TestLinearSegment < Test::Unit::TestCase
  D = 0.001
  
  def test_segment
    seg = LinearSegment.new(12, 25, 2.5, 4.5)
    
    assert !seg.defines?(11), "This frame is outside the segment"
    assert !seg.defines?(26), "This frame is outside the segment"
    assert seg.defines?(12), "Frame 12 defined"
    assert seg.defines?(24), "Frame 24 defined"
    
    assert_in_delta 2.8076, seg.value_at(14), D
    assert_in_delta 2.9615, seg.value_at(15), D
  end
end


class TestConstantPrepolate < Test::Unit::TestCase
  def test_segment
    seg = ConstantPrepolate.new(12, 234.5)
    assert seg.defines?(11)
    assert !seg.defines?(12)
    assert !seg.defines?(13)
    assert seg.defines?(-1234)
    assert_equal 234.5, seg.value_at(12)
  end
end

class TestHermiteSegment < Test::Unit::TestCase
  D = 0.001
  
  def test_last_curve_segment
    refdata = %w(
      258.239
      257.937
      257.074
      255.674
      253.759
      251.352
      248.476
      245.152
      241.405
      237.255
      232.727
      227.842
      222.624
      217.094
      211.276
      205.192
      198.865
      192.317
      185.571
      178.65
      171.576
      164.372
      157.06
      149.664
      142.205
      134.707
      127.192
      119.683
      112.202
      104.772
      97.4151
      90.1547
      83.0132
      76.0132
      69.1772
      62.528
      56.0881
      49.8802
      43.9269
      38.2508
      32.8746
      27.8209
      23.1124
      18.7715
      14.8212
      11.2838
      8.18198
      5.53853
      3.37598
      1.71692
      0.584045
      0.0
    ).map{|e| e.to_f }
    
    herm = HermiteSegment.new(
      time_from = 149,
      time_to = 200,
      value1 = 258.239,
      value2 = 0,
      tangent1 = -0.0149286,
      tangent2 = -0.302127
    )
    
    interpolated = (149..200).map(&herm.method(:value_at))
    
    refdata.zip(interpolated).each do | ref, actual |
      assert_in_delta ref, actual, D, "Interpolated value should be in delta"
    end
  end
  
  def test_first_curve_segment
    refdata = %w(
    222.919
    222.543
    221.735
    220.506
    218.867
    216.83
    214.406
    211.608
    208.445
    204.931
    201.075
    196.89
    192.387
    187.578
    182.473
    177.085
    171.425
    165.503
    159.333
    152.924
    146.29
    139.44
    132.386
    125.141
    117.715
    110.119
    102.366
    94.4661
    86.4316
    78.2735
    70.0034
    61.6327
    53.1728
    44.6353
    36.0314
    27.3727
    18.6705
    9.93645
    1.18185
    -7.58185
    -16.3432
    -25.0907
    -33.813
    -42.4985
    -51.136
    -59.714
    -68.2209
    -76.6454
    -84.9759
    -93.2012
    -101.31
    -109.29
    -117.131
    -124.82
    -132.347
    -139.7
    -146.868
    -153.839
    -160.601
    -167.144
    -173.456
    -179.525
    -185.34
    -190.889
    -196.162
    -201.146
    -205.83
    -210.204
    -214.254
    -217.97
    -221.341
    -224.355
    -227.0
    ).map{|e| e.to_f }
    
    herm = HermiteSegment.new(
      time_from = 22,
      time_to = 94,
      value1 = 222.919,
      value2 = -227.0,
      tangent1 = -0.156017,
      tangent2 = -2.45723
    )
    
    interpolated = (22..94).map(&herm.method(:value_at))
    
    (22..94).to_a.zip(refdata, interpolated).each do | frame, ref, actual |
      assert_in_delta ref, actual, D, "At #{frame} Interpolated value should be in delta"
    end
  end
end

class TestLinearPrepolate < Test::Unit::TestCase
  def test_segment
    seg = LinearPrepolate.new(123, -4, 2)
    assert seg.defines?(122)
    assert seg.defines?(-99999)
    assert_equal( -2, seg.value_at(124))
    assert_equal( -52, seg.value_at(99))
  end
end

class TestLinearExtrapolate < Test::Unit::TestCase
  def test_segment
    seg = LinearExtrapolate.new(123, -4, 2)
    assert seg.defines?(123)
    assert seg.defines?(9999999999)
    assert !seg.defines?(122)
    assert_equal( -2, seg.value_at(124))
    assert_equal 198, seg.value_at(224)
  end
end

