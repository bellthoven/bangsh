b.module.require str

function b.test.str_replace () {
  local foo="Testing"

  b.unittest.assert_equal "$(b.str.replace foo ing ong)" "Testong"
  b.unittest.assert_equal "$(b.str.replace foo t X)" "TesXing"
  b.unittest.assert_equal "$(b.str.replace foo not lala)" "Testing"
}

function b.test.str_part () {
  local foo="Testing"

  b.unittest.assert_equal "$(b.str.part foo 2 3)" "sti"
  b.unittest.assert_equal "$(b.str.part foo 2)" "sting"
  b.unittest.assert_equal "$(b.str.part foo -2)" "ng"
  b.unittest.assert_equal "$(b.str.part foo 0 -2)" "Testi"
  b.unittest.assert_raise b.str.part InvalidArgumentsException
}

function b.test.str_trim () {
  b.unittest.assert_equal "left trim" "$(b.str.trim ' left trim')"
  b.unittest.assert_equal "right trim" "$(b.str.trim 'right trim ')"
  b.unittest.assert_equal "both trim" "$(b.str.trim ' both trim ')"
  b.unittest.assert_equal "no trim" "$(b.str.trim 'no trim')"
}

