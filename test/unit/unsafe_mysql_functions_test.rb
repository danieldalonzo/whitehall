require 'test_helper'

class UnsafeMySQLFunctionsTest < ActiveSupport::TestCase

  def unsafe_functions
    %w{
      FOUND_ROWS()
      GET_LOCK()
      IS_FREE_LOCK()
      IS_USED_LOCK()
      LOAD_FILE()
      MASTER_POS_WAIT()
      RAND()
      RELEASE_LOCK()
      ROW_COUNT()
      SESSION_USER()
      SLEEP()
      SYSDATE()
      SYSTEM_USER()
      USER()
      UUID()
      UUID_SHORT()
    }
  end

  def unsafe_function_regex
    escaped_functions = unsafe_functions.map { |function| Regexp.escape(function) }
    Regexp.new(
      "(" +
        escaped_functions.join("|") +
      ")"
    )
  end

  test "no uses of MySQL functions which are unsafe with statement-based replication" do
    files = Dir.glob(File.join(Rails.root, '**', '*.rb'))
    bad_files = files.select do |filename|
      next if filename == File.expand_path(__FILE__)

      match = false
      File.open(filename) do |file|
        match = file.grep(unsafe_function_regex).any?
      end
      match
    end
    message = %{Found calls to MySQL functions which are unsafe with statement-based replication. For more details: http://dev.mysql.com/doc/refman/5.5/en/replication-rbr-safe-unsafe.html}
    assert_equal [], bad_files, message
  end
end
