#!/bin/bash

source ../src/bang.sh
is_module? "unittest" && source $(resolve_module_path "unittest")

source ./bang.sh
source ./bang_opt.sh

b.unittest.run_tests
