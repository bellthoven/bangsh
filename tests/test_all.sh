#!/bin/bash

source ../src/bang.sh
require_module unittest

source ./bang.sh
source ./bang_opt.sh

b.unittest.run_tests
