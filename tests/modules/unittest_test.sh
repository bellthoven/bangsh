#!/bin/bash

function b.test.assert_raise () {
  function catch_it () { b.raise TestingException ; }
  b.unittest.assert_raise catch_it TestingException
}
