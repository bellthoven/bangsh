#!/bin/bash

require_module "str"

function b.test.str_replace () {
  local foo="Testing"

  b.unittest.assert_equal "$(b.str.replace foo ing ong)" "Testong"
  b.unittest.assert_equal "$(b.str.replace foo t X)" "TesXing"
  b.unittest.assert_equal "$(b.str.replace foo not lala)" "Testing"
}

function b.test.str_sub () {
  local foo="Testing"

  b.unittest.assert_equal "$(b.str.sub foo 2 3)" "sti"
  b.unittest.assert_equal "$(b.str.sub foo 2)" "sting"
  b.unittest.assert_equal "$(b.str.sub foo -2)" "ng"
  b.unittest.assert_equal "$(b.str.sub foo 0 -2)" "Testi"
  b.unittest.assert_raise b.str.sub InvalidArgumentsException
}

b.unittest.add_test_case b.test.str_replace "Test b.str.replace"
b.unittest.add_test_case b.test.str_sub "Test b.str.sub"
