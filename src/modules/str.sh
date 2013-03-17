## Replaces a given string to another in a string variable
## @param varname - the name of the variable
## @param search - the string to be searched
## @param replace - the string to be replaced by
function b.str.replace {
  local varname="$(eval echo \$$1)" search="$2" replace="$3"
  echo ${varname/$search/$replace}
}

## Returns a part of the string. If no length is given,
## it will return until the last char of the string. Negative
## lengths are relative from the back of the string
## @param varname - the name of the variable
## @param offset - the starting offset
## @param length - the length of chars to include
function b.str.sub {
  local varname="$(eval echo \$$1)"
  if [ $# -eq 3 ]; then
    echo ${varname: $2:$3}
  elif [ $# -eq 2 ]; then
    echo ${varname: $2}
  else
    b.raise InvalidArgumentsException
  fi
}
