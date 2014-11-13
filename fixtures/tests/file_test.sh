function b.test.its_success () {
  b.unittest.assert_equal 'a' 'a'
}

function b.test.error () {
  b.unittest.assert_equal 'a' 'b'
}
