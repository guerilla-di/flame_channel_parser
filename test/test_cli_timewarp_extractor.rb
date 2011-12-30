require "helper"

class TestCliTimewarpExtractor < Test::Unit::TestCase
  
  BINARY = File.expand_path(File.dirname(__FILE__) + "/../bin/framecurve_from_flame")
  FC_PATH = File.expand_path(File.dirname(__FILE__)) + "/timewarp_examples/TW_016_010_v01.framecurve.txt"
  TW_PATH = File.expand_path(File.dirname(__FILE__)) + "/timewarp_examples/TW_016_010_v01.timewarp"
  
  # Run the binary under test with passed options, and return [exit_code, stdout_content, stderr_content]
  def cli(commandline_arguments)
    CLITest.new(BINARY).run(commandline_arguments)
  end
  
  def delete_test_files
    File.unlink(FC_PATH) if File.exist?(FC_PATH)
  end
  
  alias_method :setup, :delete_test_files
  alias_method :teardown, :delete_test_files
  
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
    status, output, e = cli(" " + TW_PATH)
    assert_equal '', output
    assert File.exist?(FC_PATH)
    
    content = File.read(FC_PATH)
    assert content.include?("framecurve.org/"), "Should include the framecurve URL"
    assert_equal 0, status
    assert_equal 428, content.split("\r\n").length, "Should have output 428 lines to file (first 2 lines are comments)"
  end
end