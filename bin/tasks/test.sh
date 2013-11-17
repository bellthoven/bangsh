b.module.require unittest
b.module.require path

# # Running tests
#
# Run tests that follows `unittest` standards. The standard is the following:
#
# Files with the suffix `_test.sh` will be scanned and sourced in order to
# execute the functions declared in them prefix with `b.test.`. Each file can
# have one function called `b.unittest.setup` which will be called before each
# test case and a single `b.unittest.teardown` which will be called after each
# test case has run - had it fail or not.
#
# As the test files are independent from each other, it is necessary to load
# any external resource in each file, although it is *not* necessary to include
# the `unittest` module. It is loaded already for all the tests.
#
# By default, the final output will be printed with colors. This behaviour can
# be disabled by specifing the option `--no-colors` when running the files.
#
# ## Examples of use:
#
# ```
# $ bang test
# ```
#
# By giving no args, the default behaviour is to scan `tests/` directory for
# files suffixed by `_test.sh`.
#
# If you want to test some specific files you can specify them following the
# `test` param as shown below:
#
# ```
# $ bang test tests/a_single_test.sh
# ```
#
# Multiples files can be given. When the argument passed is a directory, it
# scans through this directory for files matching the pattern `*_test.sh` as well.
# So, you can use it like this:
#
# ```
# $ bang test tests/a_single_test.sh tests/modules/ tests/sockets/tcp_test.sh
# ```
#
# To disable the colors just add `--no-colors` options anywhere after `test`
# task name.
#
# ```
# $ bang test --no-colors
# $ bang test tests/a_single_test.sh --no-colors
# $ bang test tests/a_single_test.sh --no-colors tests/modules/
# ```
function btask.test.run () {
  echo "$*" | grep -q -v '\--no-colors'
  local USE_COLORS=$?

  # Receives the passed args and removes the valid option `--no-colors`
  local files="$(echo "$@" | sed 's/--no-colors//')" \
        base_path="$(b.path.expand `b.get 'bang.test_base_path'`)" \
        # Files used for communication between tests since they are run
        # isolated from each other
        failed_tests="$(mktemp -t bang.failing.XXXX)" \
        passed_tests="$(mktemp -t bang.passing.XXXX)" \
        test_error_msgs="$(mktemp -t bang.tmp.error_msgs.XXXX)" \
        test_errors="$(mktemp -t bang.error_msgs.XXXX)" \
        # colors
        green="" red="" reset=""

  # If there is no option `--no-colors` passed as arg, setup the colors than
  if [ $USE_COLORS -eq 0 ]; then
    green="\e[32m" red="\e[91m" reset="\e[0;0m"
  fi

  local files_to_be_tested="$(_expand_files_to_be_tested ${files:-$base_path/tests})"

  if [ -n "$files_to_be_tested" ]; then
    time for file in $files_to_be_tested; do
      (
        tests_path="$(b.get bang.test_base_path)"
        relative_path="${file#tests_path}"

        _run_tests
      )
    done

    local passed_tests_count=$(cat "$passed_tests" | wc -l) \
          failed_tests_count=$(cat "$failed_tests" | wc -l)

    _print_final_output
  fi

  rm "$failed_tests" "$passed_tests" "$test_error_msgs" "$test_errors"
}

# Internal: Expand passed args into filenames so that they can be sourced and
# scanned for test cases.
#
# Example:
#
# ```
# _expand_into_files tests/ # lookup for `tests/**/*_test.sh` files
# _expand_into_files tests/a_single_test.sh tests/modules/ # lookup for `tests/a_single_test.sh tests/modules/**/*_test.sh`
# ```
function _expand_files_to_be_tested () {
  local files_to_be_tested="" path=""
  while [ $# -gt 0 ]; do
    if [ "${1:0:1}" = "/" ]; then
      path="$1"
    else
      path="$(b.path.expand $base_path/$1)"
    fi

    if b.path.dir? "$path"; then
      files_to_be_tested="$files_to_be_tested $(_find_files $path)"
    elif b.path.file? "$path"; then
      files_to_be_tested="$files_to_be_tested $path"
    else
      b.abort "It was not possible to source the file '$1'"
    fi
    shift
  done
  echo "$files_to_be_tested" | tr ' ' '\n' | sort -u
}

function _find_files () {
  find "$1" -type f -name '*_test.sh'
}

# Internal: Sources a file, run test cases in it and output the result.
function _run_tests () {
  source "$file"
  # Uses `unittest` API to find test cases in the sourced file
  for test_case in $(b.unittest.find_test_cases); do
    # Uses `unittest` API to run a test and return whether it passed or failed
    if b.unittest.run_successfuly? "$test_case" 2> "$test_error_msgs"; then
      _display_passing_test
      echo "$relative_path::$test_case" >> "$passed_tests"
    else
      _display_failing_test
      echo "$relative_path::$test_case" >> "$failed_tests"
      _format_error_to_final_output &>> "$test_errors"

      # Cleanup error messages outputed by the test case
      > "$test_error_msgs"
    fi
  done
}

function _display_passing_test () {
  echo -ne "${green}.$reset"
}

function _display_failing_test () {
  echo -ne "${red}F$reset"
}

function _print_final_output () {
  local color="$green"
  if [ -s "$test_errors" ]; then
    color="$red"
    echo
    echo "Check the following error messages:"
    cat "$test_errors"
  fi

  echo
  printf "${color}Tests "
  printf "(Passed: %i / Failed: %i)" $passed_tests_count $failed_tests_count
  printf "$reset\n"
}

function _format_error_to_final_output () {
  echo
  echo -e "${red}${relative_path}${reset}"
  echo -e "    ${red}${test_case}${reset}"
  echo
  cat "$test_error_msgs" | sed "s/^/    /"
}
