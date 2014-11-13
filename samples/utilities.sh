#!/usr/bin/env bang run

SCRIPT_PATH=$(realpath $0)
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
BANG_DIR=$(realpath "$SCRIPT_DIR/../src/")

source "$BANG_DIR/bang.sh"

TEST_ARRAY=(one two three)
in_array? "one" TEST_ARRAY && echo 'it is in array'

declare -A TEST_HASH=(["foo"]="bar")
key_exists? "foo" TEST_HASH && echo "${TEST_HASH['foo']}"

function foo () {
  echo 'it is a func'
}
is_function? foo && foo
