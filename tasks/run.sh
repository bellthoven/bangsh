btask.run.run () {
  local working_dir="$(b.get bang.working_dir)"
  local file="$1"
  shift

  . "${working_dir}/$file"
}
