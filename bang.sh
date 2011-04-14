#!/bin/sh
# vim: foldmethod=marker foldmarker={,}
# TODO: verificar se uma opt já não é uma flag e vice versa
# BASH_SOURCE - BASH_ARGV - BASH_LINENO - FUNCNAME

# Declarations =)
declare -A _BANG_FLAG_ARGS=()
declare -A _BANG_ARGS=()
declare -A _BANG_ALIASES=()
declare -A _BANG_PARSED_ARGS=()
_BANG_PARSED_FLAGS=()
_BANG_REQUIRED_ARGS=()

# Adds an option with a description to the software
# @params opt - Option to be added
# @params description - Description of th opt
function bang_addopt () {
	local opt="$1" description="$2"
	if [ ! -z "$opt" ]; then
		key_exists "$flag" "_BANG_FLAG_ARGS" && bang_raise_error "Option '$opt' already exists and cannot be added again."
		_BANG_ARGS+=(["$opt"]="$description")
		return 0
	fi
	return 1
}

# Adds a flag with a description to the software
# @params flag - Flag to be added
# @params description - Description of the flag
function bang_addflag () {
	local flag="$1" description="$2"
	if [ ! -z "$flag" ]; then
		key_exists "$flag" "_BANG_FLAG_ARGS" && bang_raise_error "Flag '$flag' already exists and cannot be added again."
		_BANG_FLAG_ARGS+=(["$flag"]="$description")
		return 0
	fi
	return 1
}

# Adds an alias for an existing option or flag
# @params opt - Option to be aliased
# @params [aliases ...] - Aliases of the option
function bang_addalias () {
	local opt="$1" total="$#"
	if [ ! -z "$opt" ] && [ $total -gt 1 ]; then
		local sum=0
		key_exists "$opt" "_BANG_ARGS" && sum=$(($sum + 1))
		key_exists "$opt" "_BANG_FLAG_ARGS" && sum=$(($sum + 1))
		# option not found
		test $sum -ne 1 && bang_raise_error "Option '$opt' does not exist, no alias can be added."
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
function bang_required_args () {
	local i=""
	if [ $# -gt 0 ]; then
		for i in $(seq 1 $#); do
			local opt=$(eval "echo \$$i")
			if key_exists "$opt" "_BANG_ARGS" || key_exists "$opt" "_BANG_FLAG_ARGS"; then
				_BANG_REQUIRED_ARGS=("$opt" "${_BANG_REQUIRED_ARGS[@]}")
			fi
		done
		return 0
	fi
	return 1
}

# Checks if the flag is set
# @params flag - Flag to be checked
function bang_hasflag () {
	in_array "$1" "_BANG_PARSED_FLAGS" && return 0
	return 1
}

# Returns the value of the option
# @params opt - Opt which value is to be returned
function bang_getopt () {
	echo "${_BANG_PARSED_ARGS[$1]}"
}

# Shows usage informations
function bang_show_usage() {
	echo -e "\nShowing script usage:\n"
	local opt=""
	echo "Options:"
	for opt in "${!_BANG_ARGS[@]}"; do
		local fullopt="$opt" alias=""
		for alias in "${!_BANG_ALIASES[@]}"; do
			test "$opt" = "${_BANG_ALIASES[$alias]}" && fullopt="$fullopt|$alias"
		done
		local req=" "
		in_array "$opt" "_BANG_REQUIRED_ARGS" && req="(Required) "
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
		in_array "$opt" "_BANG_REQUIRED_ARGS" && req="(Required) "
		echo -e "$fullopt \t\t$req${_BANG_FLAG_ARGS[$opt]}"
	done
	exit 0
}

# Returns the option value passed in command line
function bang_getopt () {
	local opt="$1"
	echo $_BANG_ARGV
}

# Raises an error an exit the code
# @params [msg ...] - Message of the error to be raised
function bang_raise_error () {
	print_e "The program was aborted due an error:\n\n\t$*"
	exit 2
}

# Parses the arguments of command line
function bang_init () {
	local -i i=1
	for (( ; $i <= $# ; i++ )); do
		local arg=$(eval "echo \$$i")
		if bang_isopt "$arg"; then
			local ii=$(($i + 1))
			local nextArg=$(eval "echo \$$ii")
			if [ -z "$nextArg" ] || bang_isopt "$nextArg" || bang_isflag "$nextArg"; then
				bang_raise_error "Option '$arg' requires an argument."
			else
				arg=$(bang_alias2opt "$arg")
				_BANG_PARSED_ARGS+=(["$arg"]="$nextArg")
				let i++
			fi
		elif bang_isflag "$arg"; then
			arg=$(bang_alias2opt "$arg")
			_BANG_PARSED_FLAGS+=("$arg")
		fi
	done
}

function bang_check_required_args() {
	local reqopt=""
	for reqopt in "${_BANG_REQUIRED_ARGS[@]}"; do
		if ! key_exists "$reqopt" "_BANG_PARSED_ARGS" && ! in_array "$reqopt" "_BANG_PARSED_FLAGS"; then
			bang_raise_error "Option '$reqopt' is required and was not especified"
		fi
	done
}

# Translates aliases to real option
function bang_alias2opt () {
	local arg="$1"
	if key_exists "$arg" "_BANG_ALIASES"; then
		echo "${_BANG_ALIASES[$arg]}"
		return 0
	fi
	echo "$arg"
	return 1
}

# Checks if the argument is an option
# @params arg - Argument to be checked
function bang_isopt () {
	local arg="$1"
	key_exists "$arg" "_BANG_ARGS" && return 0
	key_exists "$arg" "_BANG_ALIASES" && key_exists "${_BANG_ALIASES[$arg]}" "_BANG_ARGS" && return 0
	return 1
}

# Checks if the argument is a flag
# @params arg - Argument to be checked
function bang_isflag () {
	local arg="$1"
	key_exists "$arg" "_BANG_FLAG_ARGS" && return 0
	key_exists "$arg" "_BANG_ALIASES" && key_exists "${_BANG_ALIASES[$arg]}" "_BANG_FLAG_ARGS" && return 0
	return 1
}

# Checks if the element is in the given array name
# @params element - element to be searched in array
# @params array - name of the array variable to search in
function in_array () {
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
function key_exists () {
	local key="$1" array="$2"
	test -z "$key" -o -z "$array" && return 1
	array=$(sanitize_arg "$array")
	echo "$(eval echo \"\${!$array[@]}\")" | grep -wq "$(escape_arg $key)"
	return $?
}

# Returns the escaped arg (turns -- into \--)
# @params arg - Argument to be escaped
function escape_arg () {
	local arg="$1"
	if [ ${arg:0:1} == '-' ]; then
		arg="\\$arg"
	fi
	echo "$arg"
}

# Returns the sinitized arg
# @params arg - Argument to be sinitized
function sanitize_arg () {
	local arg="$1"
	arg=$(echo "$arg" | sed 's/[;& ]//g')
	echo "$arg"
}

# Print to the stderr
# @params [text ...] - Text to be printed in stderr
function print_e () {
	echo -e "$*" >&2
}
