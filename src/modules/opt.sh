#!/bin/bash
# Option parser module

declare -A _BANG_ALIASES=()
declare -A _BANG_ARGS=()
declare -A _BANG_FLAG_ARGS=()
declare -A _BANG_PARSED_ARGS=()
_BANG_PARSED_FLAGS=()
_BANG_REQUIRED_ARGS=()

function b.opt {
	_BANG_ALIASES=()
	_BANG_ARGS=()
	_BANG_FLAG_ARGS=()
	_BANG_PARSED_ARGS=()
	_BANG_PARSED_FLAGS=()
	_BANG_REQUIRED_ARGS=()
}

# Adds an option with a description to the software
# @param opt - Option to be added
# @param description - Description of th opt
function b.opt.add_opt () {
	local opt="$1" description="$2"
	if [ ! -z "$opt" ]; then
		key_exists? "$flag" "_BANG_FLAG_ARGS" && \
			b.raise_error "Option '$opt' already exists and cannot be added again."
		_BANG_ARGS+=(["$opt"]="$description")
		return 0
	fi
	return 1
}

# Adds a flag with a description to the software
# @param flag - Flag to be added
# @param description - Description of the flag
function b.opt.add_flag () {
	local flag="$1" description="$2"
	if [ ! -z "$flag" ]; then
		key_exists? "$flag" "_BANG_FLAG_ARGS" && \
			b.raise_error "Flag '$flag' already exists and cannot be added again."
		_BANG_FLAG_ARGS["$flag"]="$description"
		return 0
	fi
	return 1
}

# Adds an alias for an existing option or flag
# @param opt - Option to be aliased
# @param [aliases ...] - Aliases of the option
function b.opt.add_alias () {
	local opt="$1" total="$#"
	if [ ! -z "$opt" ] && [ $total -gt 1 ]; then
		local sum=0
		key_exists? "$opt" "_BANG_ARGS" && sum=$(($sum + 1))
		key_exists? "$opt" "_BANG_FLAG_ARGS" && sum=$(($sum + 1))
		# option not found
		test $sum -ne 1 && b.raise_error "Option '$opt' does not exist, no alias can be added."
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
# @param [opts ...] - A set of options that are required
function b.opt.required_args () {
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
# @param flag - Flag to be checked
function b.opt.has_flag? () {
	in_array? "$1" "_BANG_PARSED_FLAGS" && return 0
	return 1
}

# Returns the value of the option
# @param opt - Opt which value is to be returned
function b.opt.get_opt () {
	echo "${_BANG_PARSED_ARGS[$1]}"
	return 0
}

# Shows usage informations
function b.opt.show_usage() {
	echo -e "\nShowing script usage:\n"
	local opt=""
	echo "Options:"
	for opt in "${!_BANG_ARGS[@]}"; do
		local fullopt="$opt" alias=""
		for alias in "${!_BANG_ALIASES[@]}"; do
			test "$opt" = "${_BANG_ALIASES[$alias]}" && fullopt="$fullopt|$alias"
		done
		local req=" "
		in_array? "$opt" "_BANG_REQUIRED_ARGS" && req="(Required) "
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
		in_array? "$opt" "_BANG_REQUIRED_ARGS" && req="(Required) "
		echo -e "$fullopt \t\t$req${_BANG_FLAG_ARGS[$opt]}"
	done
	exit 0
}

# Parses the arguments of command line
function b.opt.init () {
	local -i i=1
	for (( ; $i <= $# ; i++ )); do
		local arg=$(eval "echo \$$i")
		if b.opt.is_opt? "$arg"; then
			local ii=$(($i + 1))
			local nextArg=$(eval "echo \$$ii")
			if [ -z "$nextArg" ] || b.opt.is_opt? "$nextArg" || b.opt.is_flag? "$nextArg"; then
				b.raise_error "Option '$arg' requires an argument."
			else
				arg=$(b.opt.alias2opt "$arg")
				_BANG_PARSED_ARGS+=(["$arg"]="$nextArg")
				let i++
			fi
		elif b.opt.is_flag? "$arg"; then
			arg=$(b.opt.alias2opt "$arg")
			_BANG_PARSED_FLAGS+=("$arg")
		else
			b.raise_error "Option '$arg' is not a valid option."
		fi
	done
}

# Checks for required args... if some is missing, raises an error
function b.opt.check_required_args() {
	local reqopt=""
	for reqopt in "${_BANG_REQUIRED_ARGS[@]}"; do
		if ! key_exists? "$reqopt" "_BANG_PARSED_ARGS" && \
				! in_array? "$reqopt" "_BANG_PARSED_FLAGS"; then
			b.raise_error "Option '$reqopt' is required and was not specified"
		fi
	done
}

# Translates aliases to real option
function b.opt.alias2opt () {
	local arg="$1"
	if key_exists? "$arg" "_BANG_ALIASES"; then
		echo "${_BANG_ALIASES[$arg]}"
		return 0
	fi
	echo "$arg"
	return 1
}

# Checks if the argument is an option
# @param arg - Argument to be checked
function b.opt.is_opt? () {
	local arg="$1"
	key_exists? "$arg" "_BANG_ARGS" && return 0
	key_exists? "$arg" "_BANG_ALIASES" && \
		key_exists? "${_BANG_ALIASES[$arg]}" "_BANG_ARGS" && \
		return 0
	return 1
}

# Checks if the argument is a flag
# @param arg - Argument to be checked
function b.opt.is_flag? () {
	local arg="$1"
	key_exists? "$arg" "_BANG_FLAG_ARGS" && \
		return 0
	key_exists? "$arg" "_BANG_ALIASES" && \
		key_exists? "${_BANG_ALIASES[$arg]}" "_BANG_FLAG_ARGS" && \
		return 0
	return 1
}
