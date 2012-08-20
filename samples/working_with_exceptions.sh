#!/bin/bash

SCRIPT_PATH=$(realpath $0)
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
BANG_DIR=$(realpath "$SCRIPT_DIR/../src/")

source "$BANG_DIR/bang.sh"

### Functions ###

function file_not_found () {
	echo "File was not found."
}

function file_already_exists () {
	echo "File already exists."
}

function it_is_a_directory () {
	echo "It was a directory."
}

function i_dont_know_what_it_is () {
	echo "I don't know what it is."
}

function try_again () {
	echo "Try Again"
}

function run () {
	if [ ! -e "$1" ]; then
		b.raise FileNotFoundException
	elif [ -f "$1" ]; then
		b.raise FileAlreadyExistsException
	elif [ -d "$1" ]; then
		b.raise ItIsADirectoryException
	else
		b.raise IDontKnowException
	fi
}

### Run ! ###

b.try.do run "$1"
b.catch FileNotFoundException file_not_found
b.catch FileAlreadyExistsException file_already_exists
b.catch ItIsADirectoryException it_is_a_directory
b.catch IDontKnowException i_dont_know_what_it_is
b.finally try_again
b.try.end
