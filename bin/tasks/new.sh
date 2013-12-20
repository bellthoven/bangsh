function btask.new.run () {
  local project="$(echo $1 | sed 's#/#_#g')"
  if [ -n "$project" ]; then
    (
      cd "$(b.get bang.working_dir)"
      mkdir -p "$project"
      _create_module_path
      _create_tasks_path
      _create_main_file
    )
  fi
}

function _create_module_path () {
  mkdir -p "$project/modules"
  touch "$project/modules/.gitkeep"
}

function _create_tasks_path () {
  mkdir -p "$project/tasks"
  touch "$project/tasks/.gitkeep"
}

function _create_main_file () {
  exec >> "$project/$project"
  echo '#!/usr/bin/env bash'
  echo "source '$_BANG_PATH/bang.sh'"
  chmod +x "$project/$project"
}
