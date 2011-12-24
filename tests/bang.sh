#!/bin/bash

source ../bang.sh
source ../bang_unittest.sh

_ERROR_STRING=""
function bang.raise_error_mock () {
	local errormsg="$1"
	_ERROR_STRING="$errormsg"
}

function bang.test.if_options_exists () {
	bang.add_opt --test "Testing this"
	bang.assert_true $?

	bang.is_opt? --test
	bang.assert_true $?

	local usage="$(bang.show_usage)"

	echo "$usage" | grep -q "\--test"
	bang.assert_true $?

	echo "$usage" | grep -q "Testing this"
	bang.assert_true $?
}

function bang.test.if_flag_exists () {
	bang.add_flag --help "This is a flag."
	bang.assert_true $?

	bang.is_flag? --help
	bang.assert_true $?

	local usage="$(bang.show_usage)"

	echo "$usage" | grep -q "\--help"
	bang.assert_true $?

	echo "$usage" | grep -q "This is a flag."
	bang.assert_true $?
}

function bang.test.option_and_flag_aliasing () {
	bang.add_flag --help "This is a flag"
	bang.add_opt --test "This is an option"

	bang.add_alias --help -h
	bang.assert_true $?

	bang.add_alias --test -t
	bang.assert_true $?

	bang.assert_equals --help $(bang.alias2opt -h)
	bang.assert_equals --test $(bang.alias2opt -t)
}

bang.autorun_tests
