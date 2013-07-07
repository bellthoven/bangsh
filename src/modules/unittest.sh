## Unit Test Framework

declare -A _BANG_MOCKS=()
_BANG_TESTFUNCS=()
_BANG_TESTDESCS=()
_BANG_ASSERTIONS_FAILED=0
_BANG_ASSERTIONS_PASSED=0

## Adds test cases to be executed
## @param testcase - Function with assertions
## @param description - Description of the testcase
function b.unittest.add_test_case () {
  if is_function? "$1"; then
    _BANG_TESTFUNCS+=($1)
    shift
    _BANG_TESTDESCS+=("$@")
  fi
}

## Runs all added test cases
function b.unittest.run_tests () {
  local i=0
  #b.unittest.reset_tests
  echo
  while [ $i -lt ${#_BANG_TESTFUNCS[@]} ]; do
    is_function? b.unittest.setup && b.unittest.setup
    echo "Running testcase '${_BANG_TESTFUNCS[$i]}' (${_BANG_TESTDESCS[$i]})"
    echo
    ${_BANG_TESTFUNCS[$i]}
    let i++
    is_function? b.unittest.teardown && b.unittest.teardown
  done
  echo "$i tests executed (Assertions: $_BANG_ASSERTIONS_PASSED passed / $_BANG_ASSERTIONS_FAILED failed)"
}

## Autoadd and run all test functions
function b.unittest.autorun_tests () {
  for func in $(b.unittest.find_test_cases); do
    b.unittest.add_test_case "$func"
  done
  b.unittest.run_tests
}

## Asserts a function exit code is zero
## @param return code - return code of the command
function b.unittest.assert_success () {
  if [ $1 -gt 0 ]; then
    print_e "'$@'... FAIL"
    print_e "Expected TRUE, but exit code is NOT 0"
    let _BANG_ASSERTIONS_FAILED++
    return 1
  fi
  let _BANG_ASSERTIONS_PASSED++
  return 0
}

## Asserts a functoin exit code is 1
## @param funcname - Name of the function
function b.unittest.assert_error () {
  if [ $1 -eq 0 ]; then
    print_e "'$@'... FAIL"
    print_e "Expected FALSE, but exit code is 0"
    let _BANG_ASSERTIONS_FAILED++
    return 1
  fi
  let _BANG_ASSERTIONS_PASSED++
  return 0
}

## Asserts a function output is the same as required
## @param reqvalue - Value to be equals to the output
## @param funcname - Name of the function which result is to be tested
function b.unittest.assert_equal () {
  local val="$1"
  shift
  local result="$1"
  if [ "$val" != "$result" ]; then
    print_e "'$@' equals to '$val'... FAIL"
    print_e "Expected '$val', but it was returned '$result'"
    let _BANG_ASSERTIONS_FAILED++
    return 1
  fi
  let _BANG_ASSERTIONS_PASSED++
  return 0
}

## Asserts a function will raise a given exception
## @param funcname - a string containing the name of the function which will raise an exception
## @param exception - a string containing the exception which should be raise
function b.unittest.assert_raise () {
  local fired=0
  function catch_exception () { fired=1 ; }
  b.try.do "$1"
  b.catch "$2" catch_exception
  b.try.end
  if [ $fired -eq 1 ]; then
    let _BANG_ASSERTIONS_PASSED++
  else
    let _BANG_ASSERTIONS_FAILED++
    print_e "'$1' has not raised '$2' as expected..."
  fi
  unset -f catch_exception
}

## Do a double for a function, replacing it codes for the other functions' code
## @param func1 - a string containing the name of the function to be replaced
## @param func2 - a string containing the name of the function which will replace func1
function b.unittest.double.do () {
  if is_function? "$1" && is_function? "$2"; then
    actualFunc=$(declare -f "$1" | sed '1d;2d;$d')
    func=$(declare -f "$2" | sed '1d;2d;$d')
    func_name=$(echo $1 | sed 's/\./_/g')
    _BANG_MOCKS+=(["$func_name"]="$actualFunc")
    eval "function $1 () {
      $func
    }"
  fi
}

## Undo the double for the function
## @param func - the string containing the name of the function
function b.unittest.double.undo () {
  func_name=$(echo $1 | sed 's/\./_/g')
  if key_exists? "$func_name" "_BANG_MOCKS"; then
    eval "function $1 () {
      ${_BANG_MOCKS["$func_name"]}
    }"
    unset -v _BANG_MOCKS["$func_name"]
  fi
}

function b.unittest.find_test_cases () {
  declare -f | grep '^b\.test\.' | sed 's/ ().*$//'
}
