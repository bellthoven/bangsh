declare -A _BANG_REGISTRY=()

## Sets a globally scoped variable using Registry Pattern
## @param varname - the name of the variable
## @param varvalue - the value for the variable
function b.set () {
  local index="$1"
  shift
  _BANG_REGISTRY["$index"]="$*"
}

## Gets a globally scoped variable
## @param varname - the name of the variable
function b.get () {
  echo "${_BANG_REGISTRY[$1]}"
}

## Returns whether a variable is set or not
## @param varname - the name of the variable
function b.is_set? () {
  key_exists? "$1" _BANG_REGISTRY
  return $?
}

## Unset a variable and all the ones that follow its name.
## For instance:
##   $ b.unset Bang.Test
## It would unset Bang.Test, Bang.Testing, Bang.Test.Something and so on
## @param varbeginning - the beginning of the varnames to be unsetted
function b.unset () {
  for key in "${!_BANG_REGISTRY[@]}"; do
    echo "$key" | grep -q "^$1"
    [ $? -eq 0 ] && unset _BANG_REGISTRY["$key"]
  done
}

## Return whether the argument is a valid module
## @param module - the name of the module
function is_module? () {
  b.module.exists? "$1"
}

## Checks if the element is in the given array name
## @param element - element to be searched in array
## @param array - name of the array variable to search in
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

## Checks if the given key exists in the given array name
## @param key - key to check
## @param array - name of the array variable to be checked
function key_exists? () {
  local key="$1" array="$2"
  test -z "$key" -o -z "$array" && return 1
  array=$(sanitize_arg "$array")
  echo "$(eval echo \"\${!$array[@]}\")" | grep -wq "$(escape_arg $key)"
  return $?
}

## Returns the escaped arg (turns -- into \--)
## @param arg - Argument to be escaped
function escape_arg () {
  local arg="$@"
  [ -z "$arg" ] && read arg
  if [ "${arg:0:1}" == '-' ]; then
    arg="\\$arg"
  fi
  echo -e "$arg"
}

## Returns the sinitized argument
## @param arg - Argument to be sinitized
function sanitize_arg () {
  local arg="$1"
  [ -z "$arg" ] && read arg
  arg=$(echo "$arg" | sed 's/[;&]//g' | sed 's/^ *//g ; s/ *$//g')
  echo "$arg"
}

## Checks if a function exists
## @param funcname -- Name of function to be checked
function is_function? () {
  declare -f "$1" &>/dev/null && return 0
  return 1
}

## Print to the stderr
## @param [text ...] - Text to be printed in stderr
function print_e () {
  echo -e "$*" >&2
}

## Raises an error an exit the code
## @param [msg ...] - Message of the error to be raised
function b.abort () {
  print_e "The program was aborted due to an error:\n\n\t$*"
  exit 2
}

## Raises an exception that can be cautch by catch statement
## @param exception - a string containing the name of the exception
function b.raise () {
  local exception="$1"
  shift
  if echo "${FUNCNAME[@]}" | grep -q 'b.try.do'; then
    b.set "Bang.Exception.Name" "$exception"
    b.set "Bang.Exception.Msg" "$*"
  else
    b.abort "Uncaught exception $exception: $*"
  fi
}

## Returns the last raised message by b.raise
function b.raised_message () {
  echo $(b.get "Bang.Exception.Msg")
}

## Simple implementation of the try statement which exists in other languages
## @param funcname - a string containing the name of the function that can raises an exception
function b.try.do () {
  local funcname="$1"
  if is_function? "$funcname"; then
    shift
    $funcname "$@"
  fi
}

## Catches an exception fired by b.raise and executes a function
## @param exception - a string containing the exception fired by b.raise
## @param funcname - a string containing the name of the function to handle exception
function b.catch () {
  if [ "$(b.get Bang.Exception.Name)" = "$1" ]; then
    is_function? "$2" && "$2"
  elif [ -z "$1" ]; then
    is_function? "$2" && "$2"
  fi
}

## Executes this command whether an exception is called or not
## @param funcname - a string containing the name of the function to be executed
function b.finally () {
  b.set "Bang.Exception.Finally" "$1"
}

## End a try/catch statement
function b.try.end () {
  $(b.get "Bang.Exception.Finally")
  b.unset Bang.Exception
}

function b.resolve_path () {
  local file="$1"
  shift
  while [ -n "$1" ]; do
    local file_path="$1/$file.sh"
    test -f "$file_path" && echo -n "$file_path" && return 0
    shift
  done
  return 1
}

## Check if a given dependency is executable.
##
## In case it is not raises `DependencyNotMetException`.
##
## @param dependency - a string containing the name or a path of the command to be checked
function b.depends_on () {
  local dependency="$1"
  if ! which "$dependency" &> /dev/null; then
    b.raise DependencyNotMetException "This script depends on '$dependency', but it is not executable. Check your \$PATH definition or install it before running."
    return 1
  fi
}
