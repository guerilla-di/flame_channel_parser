require "test/unit"
require "stringio"
require "tempfile"

class CliTest < Test::Unit::TestCase
  BIN_P = File.expand_path(File.dirname(__FILE__) + "/../bin/bake_flame_channel")
  
  # Run the binary under test with passed options, and return [exit_code, stdout_content, stderr_content]
  def cli(commandline_arguments)
    old_stdout, old_stderr, old_argv = $stdout, $stderr, ARGV.dup
    os, es = StringIO.new, StringIO.new
    begin
      $stdout, $stderr, verbosity = os, es, $VERBOSE
      ARGV.replace(commandline_arguments.split)
      $VERBOSE = false
      load(BIN_P)
      return [0, os.string, es.string]
    rescue SystemExit => boom # The binary uses exit(), we use that to preserve the output code
      return [boom.status, os.string, es.string]
    ensure
      $VERBOSE = verbosity
      ARGV.replace(old_argv)
      $stdout, $stderr = old_stdout, old_stderr
    end
  end
  
  def test_cli_with_no_args_produces_usage
    status, o, e = cli('')
    assert_equal -1, status
    assert_match /No input file path provided/, e
    assert_match /--help for usage information/, e
  end
  
  def test_cli_with_nonexisting_file
    status, o, e = cli(" amazing.action")
    assert_equal -1, status
    assert_match /does not exist/, e
  end
  
  def test_cli_with_proper_output
    full_path = File.expand_path(File.dirname(__FILE__)) + "/snaps/TW.timewarp"
    status, output, e = cli(" " + full_path)
    assert_equal 0, status
    assert_equal 747, output.split("\n").length, "Should have output 816 frames"
  end
  
  def test_cli_with_file_length
     full_path = File.expand_path(File.dirname(__FILE__)) + "/snaps/TW_015_010_v03.timewarp"
     status, output, e = cli(full_path)
     assert_equal 0, status
     assert_equal 476, output.split("\n").length, "Should have output 476 frames"
  end
   
  def test_cli_with_curve_limits
     full_path = File.expand_path(File.dirname(__FILE__)) + "/snaps/TW_015_010_v03.timewarp"
     status, output, e = cli(" --keyframed-range-only " + full_path)
     assert_equal 0, status
     assert_equal 531, output.split("\n").length, "Should have output 513 frames"
  end
  
  def test_cli_with_output_to_file
    tf = Tempfile.new("experiment")
    full_path = File.expand_path(File.dirname(__FILE__)) + "/snaps/TW.timewarp"
    status, output, e = cli(" --to-file " + tf.path + " " + full_path)
    
    assert_equal 0, status
    assert_equal 0, output.length
    assert_equal 747, File.read(tf.path).split("\n").length, "Should have output 816 frames"
  ensure
    tf.close!
  end
end