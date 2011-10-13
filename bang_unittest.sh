#!/bin/sh
source ./bang.sh

# Unit Test Framework

_BANG_TESTFUNCS=()
_BANG_TESTDESCS=()

# Adds test cases to be executed
# @param testcase -- Function with assertions
# @param description -- Description of the testcase
function bang_addTestCase () {
	local argnum=$(_find_separator $@)
	if function_exists "$1"; then
		_BANG_TESTFUNCS+=($1)
		_BANG_TESTDESCS+=("$2")
	fi
}

# Runs all added test cases
function bang_runTests() {
	local i=0
	while [ $i -lt ${#_BANG_TESTFUNCS[@]} ]; do
		echo "Running testcase '${_BANG_TESTFUNCS[$i]}' (${_BANG_TESTDESCS[$i]})"
		${_BANG_TESTFUNCS[$i]}
		let i++
	done
}

# Asserts a function exit code is zero
# @param funcname -- Name of the function
function bang_assertTrue () {
	if $@ &>/dev/null; then
		echo "'$@'... OK"
		return 0
	else
		echo "'$@'... FAIL"
		print_e "Expected TRUE, but exit code is FALSE for $@"
		return 1
	fi
}

# Asserts a functoin exit code is 1
# @param funcname -- Name of the function
function bang_assertFalse () {
	if $@ &> /dev/null; then
		echo "'$@'... FAIL"
		print_e "Expected FALSE, but exit code is TRUE for $@"
		return 1
	else
		echo "'$@'... OK"
		return 0
	fi
}

# Asserts a function output is the same as required
# @param reqvalue -- Value to be equals to the output
# @param funcname -- Name of the function which result is to be tested
function bang_assertEquals () {
	local val="$1"
	shift
	local result="$($@)"
	if [ "$val" == "$result" ]; then
		echo "'$@' equals to '$val'... OK"
		return 0
	else
		echo "'$@' equals to '$val'... FAIL"
		print_e "Extected '$val', but it was returned '$result'"
		return 1
	fi
}
