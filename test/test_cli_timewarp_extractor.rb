require "test/unit"
require "stringio"
require "tempfile"
require "cli_test"

class TestCli < Test::Unit::TestCase
  
  BINARY = File.expand_path(File.dirname(__FILE__) + "/../bin/bake_flame_timewarp")
  
  # Run the binary under test with passed options, and return [exit_code, stdout_content, stderr_content]
  def cli(commandline_arguments)
    CLITest.new(BINARY).run(commandline_arguments)
  end
  
  def test_cli_with_no_args_produces_usage
    status, o, e = cli('')
    assert_equal( -1, status)
    assert_match( /No input file path provided/, e)
    assert_match( /--help for usage information/, e)
  end
  
  def test_cli_with_nonexisting_file
    status, o, e = cli(" amazing.action")
    assert_equal( -1, status)
    assert_match /does not exist/, e
  end
  
  def test_cli_with_proper_output
    full_path = File.expand_path(File.dirname(__FILE__)) + "/timewarp_examples/TW_016_010_v01.timewarp"
    status, output, e = cli(" " + full_path)
    assert_equal 0, status
    assert_equal 428, output.split("\n").length, "Should have output 428 frames"
  end
end