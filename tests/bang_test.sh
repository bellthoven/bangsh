function b.test.in_array () {
  local foo=('bar')
  # True!
  in_array? "bar" "foo"
  b.unittest.assert_success $?
  # False!
  in_array? " bar" "foo"
  b.unittest.assert_error $?
}

function b.test.key_exists () {
  local -A foo=(["key"]="value")

  b.unittest.assert_success $(key_exists? "key" "foo" ; echo $?)
  b.unittest.assert_error $(key_exists? "invalid" "foo" ; echo $?)
}

function b.test.escape_arg () {
  b.unittest.assert_equal "\\--foo" $(escape_arg --foo)
  b.unittest.assert_equal "\\--foo" $(echo --foo | escape_arg)
  b.unittest.assert_equal '"--foo"' $(escape_arg "\"--foo\"")
  b.unittest.assert_equal '"--foo"' $(echo "\"--foo\"" | escape_arg)
  b.unittest.assert_equal '\-f' $(escape_arg -f)
  b.unittest.assert_equal '\-f' $(echo '-f' | escape_arg)
}

function b.test.sanitize_arg () {
  b.unittest.assert_equal "--foo" "$(sanitize_arg '--foo &')"
  b.unittest.assert_equal "--foo" "$(echo '--foo &' | sanitize_arg )"
  b.unittest.assert_equal "--foo  sudo" "$(sanitize_arg '--foo ; sudo')"
  b.unittest.assert_equal "--foo  sudo" "$(echo '--foo ; sudo' | sanitize_arg)"
}

function b.test.function_existance () {
  function testthisfunction () { echo &> /dev/null ; }
  b.unittest.assert_success $(is_function? testthisfunction ; echo $?)
  unset -f testthisfunction
  b.unittest.assert_error $(is_function? testthisfunction ; echo $?)
}

function b.test.simple_try_catch () {
  local catch_executed=0
  function command () { b.raise ExceptionName ; }
  function catchblock () { catch_executed=1 ; }
  b.try.do command
  b.catch ExceptionName catchblock
  b.try.end

  b.unittest.assert_equal 1 "$catch_executed"
  unset -f command
  unset -f catchblock
}

function b.test.multiple_catches_for_a_try () {
  local catched_executed=0 will_be_zero=0
  function command () { b.raise Exception2Name ; }
  function catchblock () { catched_executed=1 ; }
  function will_never_be_executed () { will_be_zero=1 ; }
  b.try.do command
  b.catch ExceptionName will_never_be_executed
  b.catch Exception2Name catchblock
  b.try.end

  b.unittest.assert_equal 1 $catched_executed
  b.unittest.assert_equal 0 $will_be_zero

  unset -f command
  unset -f catchblock
  unset -f will_never_be_executed
}

function b.test.finally_is_called_when_exception_is_not_raised () {
  local catched_executed=0 will_be_zero=1
  function command () { echo "dump" &> /dev/null ; }
  function catchblock () { catched_executed=1 ; }
  function will_be_zero () { will_be_zero=0 ; }

  b.try.do command
  b.catch ExceptionName catchblock
  b.finally will_be_zero
  b.try.end

  b.unittest.assert_equal 0 $catched_executed
  b.unittest.assert_equal 0 $will_be_zero

  unset -f command
  unset -f catchblock
  unset -f will_be_zero
}
