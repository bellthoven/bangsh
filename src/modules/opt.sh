#!/bin/bash
# Option parser module

## Resets this module
function b.opt.reset {
	b.unset "Bang.Opt"
}

## Adds an option with a description to the software
## @param opt - Option to be added
## @param description - Description of th opt
function b.opt.add_opt () {
	local opt="Bang.Opt.Opts.$1" description="$2"
	[ -z "$1" ] && return 1
	if b.opt.is_opt? "$(b.opt.alias2opt $1)"; then
		b.raise OptionAlreadySet \
			"Option '$1' already exists or is an alias and cannot be added again."
	elif b.opt.is_flag? "$1"; then
		b.raise FlagAlreadySet \
			"Flag '$1' already exists and cannot be overriden."
	else
		b.set "$opt" "$description"
		b.set "Bang.Opt.AllOpts" "$(b.get Bang.Opt.AllOpts) $1"
		return 0
	fi
}

## Adds a flag with a description to the software
## @param flag - Flag to be added
## @param description - Description of the flag
function b.opt.add_flag () {
	local flag="Bang.Opt.Flags.$1" description="$2"
	[ -z "$1" ] && return 1
	if b.opt.is_opt? "$(b.opt.alias2opt $1)"; then
		b.raise OptionAlreadySet
	elif b.opt.is_flag? "$1"; then
		b.raise "Flag '$flag' already exists and cannot be added again."
	else
		b.set "$flag" "$description"
		b.set "Bang.Opt.AllOpts" "$(b.get Bang.Opt.AllOpts) $1"
		return 0
	fi
}

## Adds an alias for an existing option or flag
## @param opt - Option to be aliased
## @param [aliases ...] - Aliases of the option
function b.opt.add_alias () {
	local opt="$1" total="$#"
	if [ ! -z "$opt" ] && [ $total -gt 1 ]; then
		local sum=0
		b.opt.is_opt? "$(b.opt.alias2opt $opt)" && sum=$(($sum + 1))
		b.opt.is_flag? "$opt" && sum=$(($sum + 1))
		# option not found
		[ $sum -ne 1 ] && b.raise OptionDoesNotExist "Option '$opt' does not exist, no alias can be added."
		# option found
		local i=""
		for i in $(seq 2 $total); do
			local alias=$(eval "echo Bang.Opt.Alias.\$$i")
			b.set "$alias" "$opt"
			b.set "Bang.Opt.AliasFor.$opt" "$alias $(b.get Bang.Opt.AliasFor.$opt)"
		done
		return 0
	fi
	return 1
}

## Sets the required args of the command line
## @param [opts ...] - A set of options that are required
function b.opt.required_args () {
	local i=""
	if [ $# -gt 0 ]; then
		for i in $(seq 1 $#); do
			local opt=$(eval "echo \$$i")
			opt=$(b.opt.alias2opt "$opt")
			if b.opt.is_opt? "$opt" || b.opt.is_flag? "$opt"; then
				b.set "Bang.Opt.Required" "$(b.get Bang.Opt.Required) $opt"
			fi
		done
		return 0
	fi
	return 1
}

## Checks if the flag is set
## @param flag - Flag to be checked
function b.opt.has_flag? () {
	local reqopt="$(b.opt.alias2opt $1)"
	echo $(b.get "Bang.Opt.ParsedFlag") | grep -q "^$reqopt\b\| $reqopt\b"
	return $?
}

## Returns the value of the option
## @param opt - Opt which value is to be returned
function b.opt.get_opt () {
	echo $(b.get "Bang.Opt.ParsedArg.$1")
	b.is_set? "Bang.Opt.ParsedArg.$1"
	return $?
}

## Shows usage informations
function b.opt.show_usage() {
	echo -e "\nShowing script usage:\n"
	local opt=""
	for opt in $(b.get "Bang.Opt.AllOpts"); do
		local fullopt="$opt" alias=""
		for aliasname in $(b.get "Bang.Opt.AliasFor.$opt"); do
			fullopt="$fullopt|$aliasname"
		done
		b.opt.is_opt? "$opt" && fullopt="$fullopt <value>\t\t"
		b.opt.is_required? "$opt" && fullopt="$fullopt (Required)"
		local desc=""
		b.opt.is_opt? "$opt" && desc="$(b.get Bang.Opt.Opts.$opt)"
		b.opt.is_flag? "$opt" && desc="$(b.get Bang.Opt.Flags.$opt)"
		[ ! -z "$desc" ] && fullopt="$fullopt\n\t\t$desc\n"
		echo -e "$fullopt"
	done
	#echo "Options:"
	#for opt in "${!_BANG_ARGS[@]}"; do
	#	local fullopt="$opt" alias=""
	#	for alias in "${!_BANG_ALIASES[@]}"; do
	#		test "$opt" = "${_BANG_ALIASES[$alias]}" && fullopt="$fullopt|$alias"
	#	done
	#	local req=" "
	#	in_array? "$opt" "_BANG_REQUIRED_ARGS" && req="(Required) "
	#	echo -e "$fullopt <value>\t\t$req${_BANG_ARGS[$opt]}"
	#done
	#echo "Flags:"
	#opt=""
	#for opt in "${!_BANG_FLAG_ARGS[@]}"; do
	#	local fullopt="$opt" alias=""
	#	for alias in "${!_BANG_ALIASES[@]}"; do
	#		test "$opt" = "${_BANG_ALIASES[$alias]}" && fullopt="$fullopt|$alias"
	#	done
	#	local req=" "
	#	in_array? "$opt" "_BANG_REQUIRED_ARGS" && req="(Required) "
	#	echo -e "$fullopt \t\t$req${_BANG_FLAG_ARGS[$opt]}"
	#done
	exit 0
}

## Parses the arguments of command line
function b.opt.init () {
	local -i i=1
	for (( ; $i <= $# ; i++ )); do
		local arg=$(eval "echo \$$i")
		arg=$(b.opt.alias2opt $arg)
		if b.opt.is_opt? "$arg"; then
			local ii=$(($i + 1))
			local nextArg=$(eval "echo \$$ii")
			if [ -z "$nextArg" ] || b.opt.is_opt? "$nextArg" || b.opt.is_flag? "$nextArg"; then
				b.raise ArgumentError "Option '$arg' requires an argument."
			else
				b.set "Bang.Opt.ParsedArg.$arg" "$nextArg"
				let i++
			fi
		elif b.opt.is_flag? "$arg"; then
			b.set "Bang.Opt.ParsedFlag" "$(b.get Bang.Opt.ParsedFlag) $arg"
		else
			b.raise ArgumentError "Option '$arg' is not a valid option."
		fi
	done
}

## Checks for required args... if some is missing, raises an error
function b.opt.check_required_args() {
	local reqopt=""
	for reqopt in $(b.get Bang.Opt.Required); do
		is_opt=$(b.is_set? "Bang.Opt.ParsedArg.$reqopt" ; echo $?)
		is_alias=$(b.opt.has_flag? "$reqopt" ; echo $?)
		sum=$(($is_opt + $is_alias))
		[ $sum -gt 1 ] && b.raise RequiredOptionNotSet "Option '$reqopt' is required and was not specified"
	done
	return 0
}

## Translates aliases to real option
function b.opt.alias2opt () {
	local arg="$1"
	if b.is_set? "Bang.Opt.Alias.$arg"; then
		echo $(b.get "Bang.Opt.Alias.$arg")
		return 0
	fi
	echo "$arg"
	return 1
}

## Checks if the argument is an option
## @param arg - Argument to be checked
function b.opt.is_opt? () {
	local arg="$1" opt="$(b.opt.alias2opt $1)"
	b.is_set? "Bang.Opt.Opts.$opt"
	return $?
}

## Checks if the argument is a flag
## @param arg - Argument to be checked
function b.opt.is_flag? () {
	local opt="$(b.opt.alias2opt $1)"
	b.is_set? "Bang.Opt.Flags.$opt"
	return $?
}

function b.opt.is_required? () {
	echo $(b.get Bang.Opt.Required) | grep -q "^$1\b\| $1\b"
	return $?
}
