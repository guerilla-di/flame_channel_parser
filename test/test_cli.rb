require "helper"

class TestCli < Test::Unit::TestCase
  
  def setup
    binary = File.expand_path(File.dirname(__FILE__) + "/../bin/bake_flame_channel")
    @app = CLITest.new(binary)
  end
  
  def test_cli_with_no_args_produces_usage
    status, o, e = @app.run('')
    assert_equal -1, status
    assert_match /No input file path provided/, e
    assert_match /--help for usage information/, e
  end
  
  def test_cli_with_nonexisting_file
    status, o, e = @app.run(" amazing.action")
    assert_equal -1, status
    assert_match /does not exist/, e
  end
  
  def test_cli_with_proper_output
    full_path = File.expand_path(File.dirname(__FILE__)) + "/snaps/TW.timewarp"
    status, output, e = @app.run(" " + full_path)
    assert_equal 0, status
    assert_equal 747, output.split("\n").length, "Should have output 816 frames"
  end
  
  def test_cli_with_file_length
     full_path = File.expand_path(File.dirname(__FILE__)) + "/snaps/TW_015_010_v03.timewarp"
     status, output, e = @app.run(full_path)
     assert_equal 0, status
     assert_equal 476, output.split("\n").length, "Should have output 476 frames"
  end
   
  def test_cli_with_curve_limits
     full_path = File.expand_path(File.dirname(__FILE__)) + "/snaps/TW_015_010_v03.timewarp"
     status, output, e = @app.run(" --keyframed-range-only " + full_path)
     assert_equal 0, status
     assert_equal 531, output.split("\n").length, "Should have output 513 frames"
  end
  
  def test_cli_with_output_to_file
    tf = Tempfile.new("experiment")
    full_path = File.expand_path(File.dirname(__FILE__)) + "/snaps/TW.timewarp"
    status, output, e = @app.run(" --to-file " + tf.path + " " + full_path)
    
    assert_equal 0, status
    assert_equal 0, output.length
    assert_equal 747, File.read(tf.path).split("\n").length, "Should have output 816 frames"
  ensure
    tf.close!
  end
end