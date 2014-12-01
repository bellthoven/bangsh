function b.test.task_run () {
  btask.run.run lero
  local output=$(b.task.run run fixtures/tests/test_run_file.sh)

  assert_equal 'bang is loaded' "$output"
  assert_equal a b
}
