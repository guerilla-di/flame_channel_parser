require "helper"

class TestCliFramecurveToFlame < Test::Unit::TestCase
  
  BINARY = File.expand_path(File.dirname(__FILE__) + "/../bin/framecurve_to_flame")
  FC_PATH = File.expand_path(File.dirname(__FILE__)) + "/timewarp_examples/simple.framecurve.txt"
  
  # Run the binary under test with passed options, and return [exit_code, stdout_content, stderr_content]
  def cli(commandline_arguments)
    CLITest.new(BINARY).run(commandline_arguments)
  end
  
  def teardown
    Dir.glob(FC_PATH + ".*").each do | export |
      File.unlink(export)
    end
  end
  
  def test_cli_with_no_args_produces_usage
    status, o, e = cli('')
    assert_equal( -1, status)
    assert_match( /No input file path provided/, e)
    assert_match( /--help for usage information/, e)
  end
  
end