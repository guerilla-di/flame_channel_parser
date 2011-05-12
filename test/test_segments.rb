require "test/unit"
require File.dirname(__FILE__) + "/../lib/flame_channel_parser"

D = 0.001

class TestConstantFunction < Test::Unit::TestCase
  def test_segment
    seg = ConstantFunction.new(123.4)
    assert seg.defines?(-1), "The segment should define this frame"
    assert seg.defines?(4567), "The segment should define this frame"
    assert_equal 123.4, seg.value_at(123), "This is the segment's constant value"
  end
end


class TestConstantSegment < Test::Unit::TestCase
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

class TestLinearSegment < Test::Unit::TestCase
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
  def test_segment
    refdata = %w(
      258.239
      257.9364989887
      257.073939604638
      255.673951522573
      253.759164417263
      251.352207963468
      248.475711835945
      245.152305709454
      241.404619258753
      237.2552821586
      232.726924083754
      227.842174708973
      222.623663709017
      217.094020758643
      211.275875532611
      205.191857705679
      198.864596952605
      192.316722948148
      185.570865367067
      178.64965388412
      171.575718174066
      164.371687911663
      157.06019277167
      149.663862428846
      142.205326557948
      134.707214833737
      127.192156930969
      119.682782524405
      112.201721288801
      104.771602898918
      97.4150570295135
      90.154713355346
      83.0132015511741
      76.0131512917566
      69.1771922518518
      62.5279541062185
      56.0880665296153
      49.8801591968007
      43.9268617825331
      38.2508039615713
      32.8746154086739
      27.8209257985994
      23.1123648061063
      18.7715621059533
      14.8211473728988
      11.2837502817016
      8.18200050712016
      5.53852772391312
      3.37596160683898
      1.71693183065645
      0.584068070123806
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
end

class TestNaturalSegment < Test::Unit::TestCase
  def test_fail
    flunk
  end
end

class TestLinearPrepolate < Test::Unit::TestCase
  def test_fail
    flunk
  end
end

class TestLinearExtrapolate < Test::Unit::TestCase
  def test_fail
    flunk
  end
end

