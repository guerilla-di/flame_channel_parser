require "helper"
require "set"

class TestCliFramecurveToFlame < Test::Unit::TestCase
  
  BINARY = File.expand_path(File.dirname(__FILE__) + "/../bin/framecurve_to_flame")
  FC_PATH = File.expand_path(File.dirname(__FILE__)) + "/timewarp_examples/simple.framecurve.txt"
  RESULTS = %w(
    simple.framecurve.txt.F_Kronos
    simple.framecurve.txt.timewarp
    simple.framecurve.txt.timewarp_node
  )
  
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
    assert_equal(1, status)
    assert_match( /No input file path provided/, e)
  end
  
  def test_cli_works
    status, o, e = cli(FC_PATH)
    assert_equal(0, status)
    files = Dir.glob(FC_PATH + ".*")
    assert_equal Set.new(RESULTS), Set.new(files.map{|f| File.basename(f)}), "Should have output these files"
    
    files.each do | path |
      channels = FlameChannelParser.parse_file_at(path)
      the_channel = channels.find{|c| c.length == 30 }
      
      assert_not_nil the_channel, "Should have exported at least one channel of 30 frames for #{path}"
    end
  end
  
end