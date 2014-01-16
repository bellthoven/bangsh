function btask.new.run () {
  local project="$1"
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
  local project_name="$(basename "$project")"
  exec >> "$project/$project_name"

  echo '#!/usr/bin/env bash'
  echo "source '$_BANG_PATH/bang.sh'"
  chmod +x "$project/$project_name"
}
