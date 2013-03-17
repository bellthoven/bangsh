#!/bin/bash

source ../src/bang.sh
require_module unittest

source ./bang.sh
source ./bang_unittest.sh
source ./bang_opt.sh
source ./bang_str.sh

b.unittest.run_tests
