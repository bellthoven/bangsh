b.module.require path

function b.unittest.setup () {
  local tmpdir="$(mktemp -d -t 'task_test.XXXX')"
  b.set 'testing.tmpdir' "$tmpdir"
}

function b.test.passing_a_project_name_as_argument () {
  local tmpdir="$(b.get 'testing.tmpdir')"
  (
    b.set 'bang.working_dir' "$tmpdir"
    b.task.run new lero
  )

  test_if_project_structure_was_created
}

function b.test.passing_a_path_as_argument () {
  local tmpdir="$(b.get 'testing.tmpdir')"

  b.task.run new "$tmpdir/lero"

  test_if_project_structure_was_created
}

function b.unittest.teardown () {
  rm -r "$(b.get 'testing.tmpdir')"
  b.unset 'testing'
}

function test_if_project_structure_was_created () {
  local tmpdir="$(b.get 'testing.tmpdir')"

  b.path.file? "$tmpdir/lero/modules/.gitkeep"
  b.unittest.assert_success $?

  b.path.file? "$tmpdir/lero/tasks/.gitkeep"
  b.unittest.assert_success $?

  b.path.file? "$tmpdir/lero/lero"
  b.unittest.assert_success "$?"

  b.path.executable? "$tmpdir/lero/lero"
  b.unittest.assert_success $?
}
