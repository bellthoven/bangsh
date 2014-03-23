#!/bin/bash
SCRIPT_PATH=$(dirname $0)

source "$SCRIPT_PATH/../src/bang.sh"

function print_how_to_install_git () {
  exec >&2

  echo 'Git is not installed. Install it before running the code'
  echo
  echo 'You may use one of the followings (or search for how to do it in your distro):'
  echo
  echo '$ apt-get install git'
  echo '$ yum install git'
  echo '$ pacman install git'

  exit 2
}

# If you have `git` installed, change it in the following line to see how it works.
b.try.do b.depends_on git
b.catch DependencyNotMetException print_how_to_install_git
b.try.end

echo 'You have it installed!'
