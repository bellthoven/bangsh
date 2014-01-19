b.module.require path

function b.test.path_dir () {
  local tempdir=$(mktemp -d -t testing.XXXX)

  b.path.dir? "$tempdir"
  b.unittest.assert_success $?

  b.path.dir? "${tempdir}XX"
  b.unittest.assert_error $?
}

function b.test.path_file () {
  local tempfile=$(mktemp -t testing.XXXX)

  b.path.file? "$tempfile"
  b.unittest.assert_success $?

  b.path.file? "${tempfile}XX"
  b.unittest.assert_error $?
}

function b.test.path_expand () {
  local tempdir=$( ( ( cd -P ${TMPDIR:-/tmp} ; echo $PWD ) ) )
  local dir=$(mktemp -d -t 'dir.XXXX') file=$(mktemp -t 'file.XXXX')
  local dirsuffix="${dir#${dir%%.*}}" filesuffix="${file#${file%%.*}}"
  ln -s "$dir" "${dir}2"

  b.unittest.assert_equal "$(b.path.expand $dir)" "$tempdir/dir$dirsuffix"
  b.unittest.assert_equal "$(b.path.expand $file)" "$tempdir/file$filesuffix"
  b.unittest.assert_equal "$(b.path.expand ${dir}2)" "$tempdir/dir$dirsuffix"

  unlink "${dir}2"
}
