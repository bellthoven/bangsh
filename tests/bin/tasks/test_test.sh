function b.test.task_test () {
  b.set 'bang.test_base_path' 'fixtures'
  local output="$( (
    unset -f b.test.task_test
    btask.test.run --no-colors
  ) )"

  echo -e "$output" | grep -q '^F\.$'
  local has_test_progress_bar=$?
  b.unittest.assert_success $has_test_progress_bar

  echo "$output" | grep -q 'Check the following error messages'
  local has_error_output=$?
  b.unittest.assert_success $has_error_output

  echo "$output" | grep -q "'b' equals to 'a'... FAIL"
  local outputs_expectation=$?
  b.unittest.assert_success $outputs_expectation

  echo "$output" | grep -q "Expected 'a', but it was returned 'b'"
  local outputs_test_error=$?
  b.unittest.assert_success $outputs_test_error

  b.unset 'bang.test_base_path'
}
