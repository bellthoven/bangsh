#!/bin/bash

source $(resolve_module_path "opt")

_ERROR_STRING=""
function bang_raise_error_double () {
	local errormsg="$1"
	_ERROR_STRING="$errormsg"
}

function b.unittest.teardown {
	b.opt
}

function b.test.if_options_exists () {
	b.opt.add_opt --test "Testing this"
	b.unittest.assert_success $?

	b.opt.is_opt? --test
	b.unittest.assert_success $?

	local usage="$(b.opt.show_usage)"

	echo "$usage" | grep -q "\--test"
	b.unittest.assert_success $?

	echo "$usage" | grep -q "Testing this"
	b.unittest.assert_success $?
}

function b.test.if_flag_exists () {
	b.opt.add_flag --help "This is a flag."
	b.unittest.assert_success $?

	b.opt.is_flag? --help
	b.unittest.assert_success $?

	local usage="$(b.opt.show_usage)"

	echo "$usage" | grep -q "\--help"
	b.unittest.assert_success $?

	echo "$usage" | grep -q "This is a flag."
	b.unittest.assert_success $?
}

function b.test.option_and_flag_aliasing () {
	b.opt.add_flag --help "This is a flag"
	b.opt.add_opt --test "This is an option"

	b.opt.add_alias --help -h
	b.unittest.assert_success $?

	b.opt.add_alias "--test" "-t"
	b.unittest.assert_success $?

	b.unittest.assert_equals --help $(b.opt.alias2opt -h)
	b.unittest.assert_equals --test $(b.opt.alias2opt -t)
}

function b.test.multiple_alias_for_single_option () {
	b.opt.add_opt --foo "Foo"
	b.opt.add_alias --foo -b
	b.opt.add_alias --foo -a
	b.opt.add_alias --foo -r

	b.unittest.assert_equals "$(b.opt.alias2opt -b)" --foo
	b.unittest.assert_equals "$(b.opt.alias2opt -a)" --foo
	b.unittest.assert_equals "$(b.opt.alias2opt -r)" --foo
}

function b.test.required_arg_not_present () {
	b.opt.add_flag --foo "\--foo arg"
	b.opt.add_alias --foo -f
	b.opt.required_args --foo

	# Double raise_error
	b.unittest.double.do "b.raise_error" "bang_raise_error_double"

	# No arguments called
	b.opt.init
	b.opt.check_required_args
	test -z "$_ERROR_STRING"
	b.unittest.assert_error $?
	echo "$_ERROR_STRING" | grep -q '\--foo'
	b.unittest.assert_success $?


	# Reset error_string
	_ERROR_STRING=""
	# Calling with long version!
	b.opt.init --foo
	b.opt.check_required_args 
	test -z "$_ERROR_STRING"
	b.unittest.assert_success $?

	# Reset error_string just to be sure =)
	_ERROR_STRING=""
	# Calling with short version!
	b.opt.init '-f'
	b.opt.check_required_args
	test -z "$_ERROR_STRING"
	b.unittest.assert_success $?

	# Undo double raise_error
	b.unittest.double.undo "b.raise_error"
}
