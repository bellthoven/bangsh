#!/bin/bash

source ../src/bang.sh
bang.require "unittest"

_ERROR_STRING=""
function bang.raise_error_double () {
	local errormsg="$1"
	_ERROR_STRING="$errormsg"
}

function bang.test.if_options_exists () {
	bang.add_opt --test "Testing this"
	bang.assert_success $?

	bang.is_opt? --test
	bang.assert_success $?

	local usage="$(bang.show_usage)"

	echo "$usage" | grep -q "\--test"
	bang.assert_success $?

	echo "$usage" | grep -q "Testing this"
	bang.assert_success $?
}

function bang.test.if_flag_exists () {
	bang.add_flag --help "This is a flag."
	bang.assert_success $?

	bang.is_flag? --help
	bang.assert_success $?

	local usage="$(bang.show_usage)"

	echo "$usage" | grep -q "\--help"
	bang.assert_success $?

	echo "$usage" | grep -q "This is a flag."
	bang.assert_success $?
}

function bang.test.option_and_flag_aliasing () {
	bang.add_flag --help "This is a flag"
	bang.add_opt --test "This is an option"

	bang.add_alias --help -h
	bang.assert_success $?

	bang.add_alias "--test" "-t"
	bang.assert_success $?

	bang.assert_equals --help $(bang.alias2opt -h)
	bang.assert_equals --test $(bang.alias2opt -t)
}

function bang.test.multiple_alias_for_single_option () {
	bang.add_opt --foo "Foo"
	bang.add_alias --foo -b
	bang.add_alias --foo -a
	bang.add_alias --foo -r

	bang.assert_equals "$(bang.alias2opt -b)" --foo
	bang.assert_equals "$(bang.alias2opt -a)" --foo
	bang.assert_equals "$(bang.alias2opt -r)" --foo
}

function bang.test.required_arg_not_present () {
	bang.add_flag --foo "\--foo arg"
	bang.add_alias --foo -f
	bang.required_args --foo

	# Double raise_error
	bang.double.do "bang.raise_error" "bang.raise_error_double"

	# No arguments called
	bang.init
	bang.check_required_args
	test -z "$_ERROR_STRING"
	bang.assert_error $?
	echo "$_ERROR_STRING" | grep -q '\--foo'
	bang.assert_success $?


	# Reset error_string
	_ERROR_STRING=""
	# Calling with long version!
	bang.init '--foo'
	bang.check_required_args 
	test -z "$_ERROR_STRING"
	bang.assert_success $?

	# Reset error_string just to be sure =)
	_ERROR_STRING=""
	# Calling with short version!
	bang.init '-f'
	bang.check_required_args
	test -z "$_ERROR_STRING"
	bang.assert_success $?

	# Undo double raise_error
	bang.double.undo "bang.raise_error"
}

function bang.test.in_array () {
	local foo=('bar')
	# True!
	bang.in_array? "bar" "foo"
	bang.assert_success $?
	# False!
	bang.in_array? " bar" "foo"
	bang.assert_error $?
}

bang.autorun_tests
