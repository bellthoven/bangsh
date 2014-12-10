# # Creating a new project
#
# This task is still very simple, although it helps a lot. It creates new
# bang-based projects and generates an executable file with the project's name.
#
# The task takes only one argument which can be the project name or a path. In
# the case only the name is given, the path used is the current directory.
#
# # Examples:
#
#     $ bang new my_project
#     # Creates:
#     #   - ./my_project
#     #   |-- modules/.gitkeep
#     #   |-- tasks/.gitkeep
#     #   |-- my_project
#
#     $ bang new projects/task_new
#     # Creates:
#     #   - ./projects/
#     #   |-- task_new/
#     #     |-- modules/.gitkeep
#     #     |-- tasks/.gitkeep
#     #     |-- task_new
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

  echo '#!/usr/bin/env bash run'
  chmod +x "$project/$project_name"
}
