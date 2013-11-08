function b.test.assert_raise () {
  function catch_it () { b.raise TestingException ; }
  b.unittest.assert_raise catch_it TestingException
}

function b.test.run_successfuly_returns_true_when_test_case_passes () {
  function a_success_case () {
    b.unittest.assert_equal 'a' 'a'
  }
  local test_passed=$( (
    _BANG_ASSERTIONS_PASSED=2

    b.unittest.run_successfuly? a_success_case &>/dev/null
    [ $? ] && [ $_BANG_ASSERTIONS_PASSED -eq 3 ]
    echo $?
  ) )
  b.unittest.assert_success $test_passed
}

function b.test.run_successfuly_returns_false_when_test_case_fails () {
  function a_fail_case () {
    b.unittest.assert_equal 'a' 'b'
  }

  local test_failed=$( (
    _BANG_ASSERTIONS_FAILED=1

    b.unittest.run_successfuly? a_fail_case &>/dev/null
    [ $? ] && [ $_BANG_ASSERTIONS_FAILED -eq 2 ]
    echo $?
  ) )
  b.unittest.assert_success $test_failed
}
