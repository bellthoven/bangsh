_BANG_MODULE_DIRS=("./modules" "$_BANG_PATH/modules")

## Includes a module file
## @param module - the name of the module
function b.module.require () {
  local module_path="$(b.module.resolve_path $1)"

  if [ -n "$module_path" ]; then
    source "$module_path"
  else
    b.raise ModuleNotFound "Module $1 was not found"
  fi
}

## Adds a directory to the end of the module lookup array of directories
## @param dirname - the path for the desired directory
function b.module.append_lookup_dir () {
  [ -z "$1" ] && return 1
  _BANG_MODULE_DIRS+=("$1")
}

## Adds a directory to the beginning of the module lookup of directories
## @param dirname - the path for the desired directory
function b.module.prepend_lookup_dir () {
  [ -z "$1" ] && return 1
  _BANG_MODULE_DIRS=("$1" "${_BANG_MODULE_DIRS[@]}")
}

## Resolves a module name for its path
## @param module - the name of the module
function b.module.resolve_path () {
  b.resolve_path "$1" "${_BANG_MODULE_DIRS[@]}"
}

## Check whether a given module name exists and is loadable
## @param module - the name of the module
b.module.exists? () {
  b.module.resolve_path "$1" &> /dev/null
}
