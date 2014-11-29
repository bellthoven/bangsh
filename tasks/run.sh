btask.run.run () {
  local working_dir="$(b.get bang.working_dir)"
  local file="$1"
  shift

  # If "$file" is not an absolute path
  if [ "${file:0:1}" != "/" ]; then
    file="$working_dir/$file"
  fi

  if b.path.file? "$file"; then
    . "$file"
  else
    b.abort "Could not run '$file' because it is not a file."
  fi
}
