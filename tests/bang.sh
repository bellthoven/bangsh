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
