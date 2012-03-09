#!/bin/bash

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

function b.test,escape_arg () {
	b.unittest.assert_equal "\\--foo" $(escape_arg --foo)
	b.unittest.assert_equal "\\--foo" $(echo --foo | escape_arg)
	b.unittest.assert_equal '"--foo"' $(escape_arg "\"--foo\"")
	b.unittest.assert_equal '"--foo"' $(echo "\"--foo\"" | escape_arg)
	b.unittest.assert_equal '"-f"' $(escape_arg -f)
	b.unittest.assert_equal '"-f"' $(echo '-f' | escape_arg)
}

function b.test.sanitize_arg () {
	b.unittest.assert_equal "--foo" "$(sanitize_arg '--foo &')"
	b.unittest.assert_equal "--foo" "$(echo '--foo &' | sanitize_arg )"
	b.unittest.assert_equal "--foo  sudo" "$(sanitize_arg '--foo ; sudo')"
	b.unittest.assert_equal "--foo  sudo" "$(echo '--foo ; sudo' | sanitize_arg)"
}

function b.test.function_existance () {
	function testthisfunction () { echo &> /dev/null ; }
	b.unittest.assert_success $(function_exists? testthisfunction ; echo $?)
	unset -f testthisfunction
	b.unittest.assert_error $(function_exists? testthisfunction ; echo $?)
}

function b.test.trim () {
	b.unittest.assert_equals "left trim" $(trim " left trim")
	b.unittest.assert_equals "right trim" $(trim "right trim ")
	b.unittest.assert_equals "both trim" $(trim " both trim ")
	b.unittest.assert_equals "no trim" $(trim "no trim")
}

b.unittest.add_test_case b.test.in_array "Test in_array function"
b.unittest.add_test_case b.test.key_exists "Test key_exists function"
b.unittest.add_test_case b.test.escape_arg "Test escape_arg function"
b.unittest.add_test_case b.test.sanitize_arg "Test sanitize_arg function"
b.unittest.add_test_case b.test.function_existance "Test function_exists function"
