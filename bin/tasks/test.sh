b.module.require unittest

function btask.test.run () {
  echo "$*" | grep -q -v '\--no-colors'
  local USE_COLORS=$?

  local base_path="$(b.get 'bang.test_base_path')" \
        failed_tests="$(mktemp -t bang.failing.XXXX)" \
        passed_tests="$(mktemp -t bang.passing.XXXX)" \
        test_error_msgs="$(mktemp -t bang.tmp.error_msgs.XXXX)" \
        test_errors="$(mktemp -t bang.error_msgs.XXXX)" \
        # colors
        green="" red="" reset=""

  if [ $USE_COLORS -eq 0 ]; then
    green="\e[32m" red="\e[91m" reset="\e[0;0m"
  fi

  time for file in $(_find_files); do
    (
      tests_path="$(b.get bang.test_base_path)"
      relative_path="${file#tests_path}"

      _run_tests
    )
  done

  local passed_tests_count=$(cat "$passed_tests" | wc -l) \
        failed_tests_count=$(cat "$failed_tests" | wc -l)

  _print_final_output

  rm "$failed_tests" "$passed_tests" "$test_error_msgs" "$test_errors"
}

function _run_tests () {
  source "$file"
  for test_case in $(b.unittest.find_test_cases); do
    if b.unittest.run_successfuly? "$test_case" 2> "$test_error_msgs"; then
      _display_passing_test
      echo "$relative_path::$test_case" >> "$passed_tests"
    else
      _display_failing_test
      echo "$relative_path::$test_case" >> "$failed_tests"
      _format_error_to_final_output &>> "$test_errors"
      # clean msgs
      > "$test_error_msgs"
    fi
  done
}

function _find_files () {
  find "$base_path/tests" -type f -name '*_test.sh'
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
