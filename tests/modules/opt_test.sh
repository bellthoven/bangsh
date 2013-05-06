#!/bin/bash

b.module.require opt

function b.unittest.teardown {
  b.opt.reset
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

  b.unittest.assert_equal --help $(b.opt.alias2opt -h)
  b.unittest.assert_equal --test $(b.opt.alias2opt -t)
}

function b.test.multiple_alias_for_single_option () {
  b.opt.add_opt --foo "Foo"
  b.opt.add_alias --foo -b
  b.opt.add_alias --foo -a
  b.opt.add_alias --foo -r

  b.unittest.assert_equal "$(b.opt.alias2opt -b)" --foo
  b.unittest.assert_equal "$(b.opt.alias2opt -a)" --foo
  b.unittest.assert_equal "$(b.opt.alias2opt -r)" --foo
}

function b.test.required_arg_not_present () {
  b.opt.add_flag --foo "\--foo arg"
  b.opt.add_alias --foo -f
  b.opt.required_args --foo

  # No arguments called
  b.opt.init
  b.unittest.assert_raise b.opt.check_required_args RequiredOptionNotSet
}

function b.test.required_arg_called_with_long_args () {
  b.opt.add_flag --foo "\--foo arg"
  b.opt.add_alias --foo -f
  b.opt.required_args --foo

  ## Calling with long version!
  b.opt.init --foo
  b.opt.check_required_args 
  b.unittest.assert_success $?
}

function b.test.required_arg_called_with_short_args () {
  b.opt.add_flag --foo "\--foo arg"
  b.opt.add_alias --foo -f
  b.opt.required_args --foo

  ## Calling with short version!
  b.opt.init '-f'
  b.opt.check_required_args
  b.unittest.assert_success $?
}

function b.test.has_flag_set () {
  b.opt.add_flag --foo "foo"
  b.opt.init --foo
  b.opt.has_flag? --foo
  b.unittest.assert_success $?
}

function b.test.has_not_flag_set () {
  b.opt.add_flag --foo "foo"
  b.opt.init
  b.opt.has_flag? --foo
  b.unittest.assert_error $?
}

function b.test.get_opt () {
  b.opt.add_opt --foo "Foo is an option"
  b.opt.init --foo "bar"
  b.unittest.assert_equal "bar" $(b.opt.get_opt --foo)
}

b.unittest.add_test_case b.test.if_options_exists "Test b.opt options"
b.unittest.add_test_case b.test.if_flag_exists "Test b.opt flags"
b.unittest.add_test_case b.test.option_and_flag_aliasing "Test both, option and flag aliasing"
b.unittest.add_test_case b.test.multiple_alias_for_single_option "Test multiple aliases for the same optino"
b.unittest.add_test_case b.test.required_arg_not_present "Test behavior for required args"
b.unittest.add_test_case b.test.required_arg_called_with_long_args "Test behavior for required args"
b.unittest.add_test_case b.test.required_arg_called_with_short_args "Test behavior for required args"
b.unittest.add_test_case b.test.has_flag_set "Test whether has_flag? returns the right exit code"
b.unittest.add_test_case b.test.has_not_flag_set "Test whether has_flag? returns the right exit code"
b.unittest.add_test_case b.test.get_opt "Test whether get_opt works"
