#!/bin/bash

BASEPATH=`dirname $0`
source "${BASEPATH}/../src/bang.sh"
require_module unittest

for file in $(find "$BASEPATH" -name '*_test.sh'); do
  echo -n "Executing tests cases in $file... "
  ( (
    source "$file"
    b.unittest.autorun_tests
  ) )
done
