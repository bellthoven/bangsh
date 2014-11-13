btask.run.run () {
  local working_dir="$(b.get bang.working_dir)"

  . "${working_dir}/$1"
}
