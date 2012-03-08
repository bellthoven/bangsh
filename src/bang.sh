#!/bin/bash
# vim: foldmethod=marker foldmarker={,}
# BASH_SOURCE - BASH_ARGV - BASH_LINENO - FUNCNAME

_BANG_PATH="$(dirname $(realpath ${BASH_ARGV[0]}))"
declare -A _BANG_FLAG_ARGS=()
declare -A _BANG_ARGS=()
declare -A _BANG_ALIASES=()
declare -A _BANG_PARSED_ARGS=()
_BANG_MODULE_DIRS=("$_BANG_PATH/modules" "./modules")
_BANG_PARSED_FLAGS=()
_BANG_REQUIRED_ARGS=()

# Source modules found in an directory
# @params module[, module2, module3, ...]
function bang.require {
	while [ ! -z "$1" ]; do
		mod_path="$(bang.resolve_module_path "$1")"
		if [ ! -z "$mod_path" ]; then
			source "$mod_path"
		else
			bang.raise_error "Module '$1' not found."
		fi
		shift
	done
}

# Return whether the argument is a valid module
# @params module - the name of the module
function bang.is_module? {
	bang.resolve_module_path "$1"
	return $?
}

# Resolves a module name for its path
# @param module - the name of the module
function bang.resolve_module_path {
	for path in $_BANG_MODULE_DIRS; do
		path=$(realpath "$path")
		[ -x "$path/$1.sh" ] && echo "$path/$1.sh" && return 0
	done
	return 1
}

# Adds an option with a description to the software
# @params opt - Option to be added
# @params description - Description of th opt
function bang.add_opt () {
	local opt="$1" description="$2"
	if [ ! -z "$opt" ]; then
		key_exists? "$flag" "_BANG_FLAG_ARGS" && bang.raise_error "Option '$opt' already exists and cannot be added again."
		_BANG_ARGS+=(["$opt"]="$description")
		return 0
	fi
	return 1
}

# Adds a flag with a description to the software
# @params flag - Flag to be added
# @params description - Description of the flag
function bang.add_flag () {
	local flag="$1" description="$2"
	if [ ! -z "$flag" ]; then
		key_exists? "$flag" "_BANG_FLAG_ARGS" && bang.raise_error "Flag '$flag' already exists and cannot be added again."
		_BANG_FLAG_ARGS+=(["$flag"]="$description")
		return 0
	fi
	return 1
}

# Adds an alias for an existing option or flag
# @params opt - Option to be aliased
# @params [aliases ...] - Aliases of the option
function bang.add_alias () {
	local opt="$1" total="$#"
	if [ ! -z "$opt" ] && [ $total -gt 1 ]; then
		local sum=0
		key_exists? "$opt" "_BANG_ARGS" && sum=$(($sum + 1))
		key_exists? "$opt" "_BANG_FLAG_ARGS" && sum=$(($sum + 1))
		# option not found
		test $sum -ne 1 && bang.raise_error "Option '$opt' does not exist, no alias can be added."
		# option found
		local i=""
		for i in $(seq 2 $total); do
			local alias=$(eval "echo \$$i")
			_BANG_ALIASES+=(["$alias"]="$opt")
		done
		return 0
	fi
	return 1
}

# Sets the required args of the command line
# @params [opts ...] - A set of options that are required
function bang.required_args () {
	local i=""
	if [ $# -gt 0 ]; then
		for i in $(seq 1 $#); do
			local opt=$(eval "echo \$$i")
			if key_exists? "$opt" "_BANG_ARGS" || key_exists? "$opt" "_BANG_FLAG_ARGS"; then
				_BANG_REQUIRED_ARGS=("$opt" "${_BANG_REQUIRED_ARGS[@]}")
			fi
		done
		return 0
	fi
	return 1
}

# Checks if the flag is set
# @params flag - Flag to be checked
function bang.has_flag? () {
	bang.in_array? "$1" "_BANG_PARSED_FLAGS" && return 0
	return 1
}

# Returns the value of the option
# @params opt - Opt which value is to be returned
function bang.get_opt () {
	echo "${_BANG_PARSED_ARGS[$1]}"
	return 0
}

# Shows usage informations
function bang.show_usage() {
	echo -e "\nShowing script usage:\n"
	local opt=""
	echo "Options:"
	for opt in "${!_BANG_ARGS[@]}"; do
		local fullopt="$opt" alias=""
		for alias in "${!_BANG_ALIASES[@]}"; do
			test "$opt" = "${_BANG_ALIASES[$alias]}" && fullopt="$fullopt|$alias"
		done
		local req=" "
		bang.in_array? "$opt" "_BANG_REQUIRED_ARGS" && req="(Required) "
		echo -e "$fullopt <value>\t\t$req${_BANG_ARGS[$opt]}"
	done
	echo "Flags:"
	opt=""
	for opt in "${!_BANG_FLAG_ARGS[@]}"; do
		local fullopt="$opt" alias=""
		for alias in "${!_BANG_ALIASES[@]}"; do
			test "$opt" = "${_BANG_ALIASES[$alias]}" && fullopt="$fullopt|$alias"
		done
		local req=" "
		bang.in_array? "$opt" "_BANG_REQUIRED_ARGS" && req="(Required) "
		echo -e "$fullopt \t\t$req${_BANG_FLAG_ARGS[$opt]}"
	done
	exit 0
}

# Raises an error an exit the code
# @params [msg ...] - Message of the error to be raised
function bang.raise_error () {
	print_e "The program was aborted due an error:\n\n\t$*"
	exit 2
}

# Parses the arguments of command line
function bang.init () {
	local -i i=1
	for (( ; $i <= $# ; i++ )); do
		local arg=$(eval "echo \$$i")
		if bang.is_opt? "$arg"; then
			local ii=$(($i + 1))
			local nextArg=$(eval "echo \$$ii")
			if [ -z "$nextArg" ] || bang.is_opt? "$nextArg" || bang.is_flag? "$nextArg"; then
				bang.raise_error "Option '$arg' requires an argument."
			else
				arg=$(bang.alias2opt "$arg")
				_BANG_PARSED_ARGS+=(["$arg"]="$nextArg")
				let i++
			fi
		elif bang.is_flag? "$arg"; then
			arg=$(bang.alias2opt "$arg")
			_BANG_PARSED_FLAGS+=("$arg")
		else
			bang.raise_error "Option '$arg' is not a valid option."
		fi
	done
}

# Checks for required args... if some is missing, raises an error
function bang.check_required_args() {
	local reqopt=""
	for reqopt in "${_BANG_REQUIRED_ARGS[@]}"; do
		if ! key_exists? "$reqopt" "_BANG_PARSED_ARGS" && ! bang.in_array? "$reqopt" "_BANG_PARSED_FLAGS"; then
			bang.raise_error "Option '$reqopt' is required and was not specified"
		fi
	done
}

# Translates aliases to real option
function bang.alias2opt () {
	local arg="$1"
	if key_exists? "$arg" "_BANG_ALIASES"; then
		echo "${_BANG_ALIASES[$arg]}"
		return 0
	fi
	echo "$arg"
	return 1
}

# Checks if the argument is an option
# @params arg - Argument to be checked
function bang.is_opt? () {
	local arg="$1"
	key_exists? "$arg" "_BANG_ARGS" && return 0
	key_exists? "$arg" "_BANG_ALIASES" && key_exists? "${_BANG_ALIASES[$arg]}" "_BANG_ARGS" && return 0
	return 1
}

# Checks if the argument is a flag
# @params arg - Argument to be checked
function bang.is_flag? () {
	local arg="$1"
	key_exists? "$arg" "_BANG_FLAG_ARGS" && return 0
	key_exists? "$arg" "_BANG_ALIASES" && key_exists? "${_BANG_ALIASES[$arg]}" "_BANG_FLAG_ARGS" && return 0
	return 1
}

# Checks if the element is in the given array name
# @params element - element to be searched in array
# @params array - name of the array variable to search in
function bang.in_array? () {
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
# @params key - key to check
# @params array - name of the array variable to be checked
function key_exists? () {
	local key="$1" array="$2"
	test -z "$key" -o -z "$array" && return 1
	array=$(sanitize_arg "$array")
	echo "$(eval echo \"\${!$array[@]}\")" | grep -wq "$(escape_arg $key)"
	return $?
}

# Returns the escaped arg (turns -- into \--)
# @params arg - Argument to be escaped
function escape_arg () {
	local arg="$@"
	if [ "${arg:0:1}" == '-' ]; then
		arg="\\$arg"
	fi
	echo -e "$arg"
}

# Returns the sinitized arg
# @params arg - Argument to be sinitized
function sanitize_arg () {
	local arg="$1"
	arg=$(echo "$arg" | sed 's/[;& ]//g')
	echo "$arg"
}

# Checks if a function exists
# @params funcname -- Name of function to be checked
function function_exists? () {
	declare -f "$1" &>/dev/null && return 0
	return 1
}

# Print to the stderr
# @params [text ...] - Text to be printed in stderr
function print_e () {
	echo -e "$*" >&2
}
