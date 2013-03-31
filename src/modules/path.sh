#!/bin/bash

## Expands a given path to its full path.
## If it has synlinks, it will be converted to the realpath.
## If it is a file, the path will also be expanded to realpath
## It does not return a trailling '/' for directories
## @params path - a path to be expanded
function b.path.expand () {
  local _DIR="$1" _FILE=""
  if [ -f "$1" ]; then
    _DIR="${1%/*}/"
    _FILE="${1/$_DIR/}"
  fi
  ( (
    if cd -P "$_DIR" &> /dev/null; then
      _REALPATH="$PWD/$_FILE"
      echo "${_REALPATH%/}"
    fi
  ) )
}

## Returns true if the passed path is a directory, false otherwise
## @params path - the path to be checked
function b.path.dir? () {
  test -d "$1"
}

## Returns true if the passed path is a file, false otherwise
## @params path - the path to be checked
function b.path.file? () {
  test -f "$1"
}
