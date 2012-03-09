#!/bin/bash
# BASH_SOURCE - BASH_ARGV - BASH_LINENO - FUNCNAME

_BANG_PATH="$(dirname $(realpath ${BASH_ARGV[0]}))"
_BANG_MODULE_DIRS=("$_BANG_PATH/modules" "./modules")

# Source modules found in an directory
# @param module[, module2, module3, ...]
function require_module () {
	while [ ! -z "$1" ]; do
		mod_path="$(b.resolve_module_path "$1")"
		if [ ! -z "$mod_path" ]; then
			source "$mod_path"
		else
			b.raise_error "Module '$1' not found."
		fi
		shift
	done
}

# Return whether the argument is a valid module
# @param module - the name of the module
function is_module? () {
	resolve_module_path "$1" &>/dev/null
	return $?
}

# Resolves a module name for its path
# @param module - the name of the module
function resolve_module_path () {
	for path in $_BANG_MODULE_DIRS; do
		path=$(realpath "$path")
		[ -x "$path/$1.sh" ] && echo "$path/$1.sh" && return 0
	done
	return 1
}

# Checks if the element is in the given array name
# @param element - element to be searched in array
# @param array - name of the array variable to search in
function in_array? () {
	local element="$1" array="$2"
	test -z "$element" -o -z "$array" && return 1
	# Sanitize!
	array=$(sanitize_arg "$array")
	local values="$(eval echo \"\${$array[@]}\")"
	element=$(escape_arg "$element")
	echo "$values" | grep -wq "$element"
	return $?
}

# Checks if the given key exists in the given array name
# @param key - key to check
# @param array - name of the array variable to be checked
function key_exists? () {
	local key="$1" array="$2"
	test -z "$key" -o -z "$array" && return 1
	array=$(sanitize_arg "$array")
	echo "$(eval echo \"\${!$array[@]}\")" | grep -wq "$(escape_arg $key)"
	return $?
}

# Returns the escaped arg (turns -- into \--)
# @param arg - Argument to be escaped
function escape_arg () {
	local arg="$@"
	if [ "${arg:0:1}" == '-' ]; then
		arg="\\$arg"
	fi
	echo -e "$arg"
}

# Returns the sinitized arg
# @param arg - Argument to be sinitized
function sanitize_arg () {
	local arg="$1"
	arg=$(echo "$arg" | sed 's/[;&]//g ; s/^\s\+\|\s\+$//g')
	echo "$arg"
}

# Checks if a function exists
# @param funcname -- Name of function to be checked
function function_exists? () {
	declare -f "$1" &>/dev/null && return 0
	return 1
}

# Print to the stderr
# @param [text ...] - Text to be printed in stderr
function print_e () {
	echo -e "$*" >&2
}

# Raises an error an exit the code
# @param [msg ...] - Message of the error to be raised
function b.raise_error () {
	print_e "The program was aborted due an error:\n\n\t$*"
	exit 2
}
