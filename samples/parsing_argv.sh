#!/bin/bash

SCRIPT_PATH=$(realpath $0)
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
BANG_DIR=$(realpath "$SCRIPT_DIR/../src/")

source "$BANG_DIR/bang.sh"
require_module opt

### Functions ###

function load_options () {
	# Help (--help and -h added as flags)
	b.opt.add_flag --help "Show usage notes"
	b.opt.add_alias --help -h

	# text (--text and -t added as options)
	b.opt.add_opt --text "Specify text to be printed"
	b.opt.add_alias --text -t

	# Set required args (will raise errors if not specified)
	b.opt.required_args --text
}

function run() {
	load_options
	b.opt.init "$@"
	if b.opt.has_flag? -h; then
		b.opt.show_usage
	else
		b.opt.check_required_args
		local text="$(b.opt.get_opt --text)"
		echo "$text"
	fi
}

# Run!
b.try.do run "$@"
b.catch ArgumentError b.opt.show_usage
b.catch RequiredOptionNotSet b.opt.show_usage
b.try.end
