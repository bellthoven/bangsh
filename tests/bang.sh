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

b.unittest.add_test_case b.test.in_array "Test in_array function"
b.unittest.add_test_case b.test.key_exists "Test key_exists function"
