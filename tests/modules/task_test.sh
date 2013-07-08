b.module.require task

function b.test.it_raises_error_when_task_does_not_exist () {
  function add_invalid_task () {
    b.task.add 'lorem'
  }

  b.unittest.assert_raise add_invalid_task TaskNotFound 
}

function b.test.it_adds_the_task_when_task_exist () {
  function does_exists () { return 0; }
  b.unittest.double.do b.task.exists? does_exists

  local description='Some description'
  b.task.add 'lorem' "$description"
  b.unittest.assert_success $?

  local key='bang.tasks.lorem'
  b.is_set? $key
  b.unittest.assert_success $?
  b.unittest.assert_equal "$description" "$(b.get $key)"
}

function b.test.it_runs_added_tasks () {
  function a_path () { echo "/path/to/task-$1.sh" ; }
  b.unittest.double.do b.task.resolve_path a_path

  local resolved_path="" func_runned=0
  function source () { resolved_path="$1" ; }
  function btask.google.run () { func_runned=1 ; }

  b.task.add 'google' 'Googles me something'
  b.task.run 'google'

  b.unittest.assert_equal "/path/to/task-google.sh" "$resolved_path"
  b.unittest.assert_equal "1" "$func_runned"
}

function b.test.it_raises_an_error_when_try_to_run_an_inexistent_task () {
  function run_task () { b.task.run 'inexistent_task' ; }

  b.unittest.assert_raise run_task TaskNotKnown
}
