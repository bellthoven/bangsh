#!/bin/bash
# vim: foldmethod=marker foldmarker={,}
# Unit Test Framework

_BANG_TESTFUNCS=()
_BANG_TESTDESCS=()

# Resets the tests like it had never happened
function bang.reset_tests {
	_BANG_ASSERTIONS_FAILED=0
	_BANG_ASSERTIONS_PASSED=0
	declare -A _BANG_MOCKS=()
}

# Adds test cases to be executed
# @param testcase -- Function with assertions
# @param description -- Description of the testcase
function bang.add_test_case () {
	if function_exists? "$1"; then
		_BANG_TESTFUNCS+=($1)
		shift
		_BANG_TESTDESCS+=("$@")
	fi
}

# Runs all added test cases
function bang.run_tests () {
	local i=0
	bang.reset_tests
	echo
	while [ $i -lt ${#_BANG_TESTFUNCS[@]} ]; do
		declare -A _BANG_FLAG_ARGS=()
		declare -A _BANG_ARGS=()
		declare -A _BANG_ALIASES=()
		declare -A _BANG_PARSED_ARGS=()
	   _BANG_PARSED_FLAGS=()
	   _BANG_REQUIRED_ARGS=()
		echo "Running testcase '${_BANG_TESTFUNCS[$i]}' (${_BANG_TESTDESCS[$i]})"
		echo
		${_BANG_TESTFUNCS[$i]}
		let i++
	done
	echo "$i tests executed (Assertions: $_BANG_ASSERTIONS_PASSED passed / $_BANG_ASSERTIONS_FAILED failed)"
}

# Autoadd and run all test functions
function bang.autorun_tests () {
	for func in $(declare -f | grep '^bang\.test\.' | sed 's/ ().*$//'); do
		bang.add_test_case "$func"
	done
	bang.run_tests
}

# Asserts a function exit code is zero
# @param return code -- return code of the command
function bang.assert_success () {
	if [ $1 -gt 0 ]; then
		print_e "'$@'... FAIL"
		print_e "Expected TRUE, but exit code is NOT 0"
		let _BANG_ASSERTIONS_FAILED++
		return 1
	fi
	let _BANG_ASSERTIONS_PASSED++
	return 0
}

# Asserts a functoin exit code is 1
# @param funcname -- Name of the function
function bang.assert_error () {
	if [ $1 -eq 0 ]; then
		print_e "'$@'... FAIL"
		print_e "Expected FALSE, but exit code is 0"
		let _BANG_ASSERTIONS_FAILED++
		return 1
	fi
	let _BANG_ASSERTIONS_PASSED++
	return 0
}

# Asserts a function output is the same as required
# @param reqvalue -- Value to be equals to the output
# @param funcname -- Name of the function which result is to be tested
function bang.assert_equals () {
	local val="$1"
	shift
	local result="$1"
	if [ "$val" != "$result" ]; then
		print_e "'$@' equals to '$val'... FAIL"
		print_e "Expected '$val', but it was returned '$result'"
		let _BANG_ASSERTIONS_FAILED++
		return 1
	fi
	let _BANG_ASSERTIONS_PASSED++
	return 0
}

# Do a double for a function, replacing it codes for the other functions' code
# @param func1 - a string containing the name of the function to be replaced
# @param func2 - a string containing the name of the function which will replace func1
function bang.double.do () {
	if function_exists? "$1" && function_exists? "$2"; then
		actualFunc=$(declare -f "$1" | sed '1d;2d;$d')
		func=$(declare -f "$2" | sed '1d;2d;$d')
		func_name=$(echo $1 | sed 's/\./_/g')
		_BANG_MOCKS+=(["$func_name"]="$actualFunc")
		eval "function $1 () {
			$func
		}"
	fi
}

# Undo the double for the function
# @param func - the string containing the name of the function
function bang.double.undo () {
	func_name=$(echo $1 | sed 's/\./_/g')
	if key_exists? "$func_name" "_BANG_MOCKS"; then
		eval "function $1 () {
			${_BANG_MOCKS["$func_name"]}
		}"
	fi
}
