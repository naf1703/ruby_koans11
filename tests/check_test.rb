require_relative "test_helper"

class CheckTest < Minitest::Test
  def with_captured_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  def test_check_asserts
    output = with_captured_stdout do
      Rake::Task['check:asserts'].invoke
    end
    assert_match(/OK/, output)
  end

  def test_check_abouts
    output = with_captured_stdout do
      Rake::Task['check:abouts'].invoke
    end
    assert_match(/OK/, output)
  end
end