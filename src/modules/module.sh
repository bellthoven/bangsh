_BANG_MODULE_DIRS=("./modules" "$_BANG_PATH/modules")

## Includes a module file
## @param module - the name of the module
function b.module.require () {
  if is_module? "$1"; then
    source "$(b.module.resolve_path $1)"
  else
    b.raise ModuleNotFound
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
  for path in "${_BANG_MODULE_DIRS[@]}"; do
    [ -f "$path/$1.sh" ] && echo "$path/$1.sh" && return 0
  done
  return 1
}
