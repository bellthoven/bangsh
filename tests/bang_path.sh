#!/bin/bash

source '../src/bang.sh'
require_module unittest
require_module path

function b.test.path_dir () {
  local tempdir=$(mktemp -d -t testing)

  b.path.dir? "$tempdir"
  b.unittest.assert_success $?

  b.path.dir? "${tempdir}XX"
  b.unittest.assert_error $?
}

function b.test.path_file () {
  local tempfile=$(mktemp -t testing)

  b.path.file? "$tempfile"
  b.unittest.assert_success $?

  b.path.file? "${tempfile}XX"
  b.unittest.assert_error $?
}

function b.test.path_expand () {
  local tempdir=$( ( ( cd -P ${TMPDIR:-/tmp} ; echo $PWD ) ) )
  local dir=$(mktemp -d -t 'dir') file=$(mktemp -t 'file')
  local dirsuffix="${dir#${dir%%.*}}" filesuffix="${file#${file%%.*}}"
  ln -s "$dir" "${dir}2"

  b.unittest.assert_equal "$(b.path.expand $dir)" "$tempdir/dir$dirsuffix"
  b.unittest.assert_equal "$(b.path.expand $file)" "$tempdir/file$filesuffix"
  b.unittest.assert_equal "$(b.path.expand ${dir}2)" "$tempdir/dir$dirsuffix"

  unlink "${dir}2"
}

b.unittest.autorun_tests
