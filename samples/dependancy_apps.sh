#!/bin/bash
#SCRIPT_PATH=$(realpath $0)
#SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
#BANG_DIR=$(realpath "$SCRIPT_DIR/../src/")

#source "$BANG_DIR/bang.sh"

source "../src/bang.sh"
b.module.require opt

# make sure environment has the right apps installed
b.opt.check_required_apps "sed git"
