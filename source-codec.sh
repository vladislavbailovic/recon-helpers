#!/bin/bash

function urlencode() {
	echo "$1" | jq -Rr @uri
}

function urlencode-all() {
	echo "$1" | xxd -p| tr -d '\n\r' | sed 's/../%&/g'
}

function urldecode() {
	echo -e ${1//%/\\x}
}
