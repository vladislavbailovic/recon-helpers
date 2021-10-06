declare -A FLAGBOOLS
declare -A FLAGDFLTS
declare -A FLAGDESCS

function flag-set() {
	flag=$1; shift
	[ "$1" == "BOOL" ] && bool="yes" || bool=$1; shift
	default=$1; shift
	desc=$1; shift
	FLAGBOOLS[$flag]=$bool
	FLAGDFLTS[$flag]=$default
	FLAGDESCS[$flag]="$desc"
}

function flag-get() {
	which=$1; shift
	found=0
	while [ $1 ]; do
		if [ "$1" != "$which" ]; then
			shift;
			continue
		fi
		found=1
		if [ "yes" == "${FLAGBOOLS[$which]}" ]; then
			echo "yes"
		else
			shift;
			echo $1
		fi
		break
	done
	if [ "$found" == "0" ]; then
		echo "${FLAGDFLTS[$which]}"
	fi
}

function flag-rest() {
	rest=""
	count=0
	while [ $1 ]; do
		next=0
		for key in "${!FLAGBOOLS[@]}"; do
			if [ "$key" != "$1" ]; then
				continue
			fi
			next=$(( next + 1 ))
			if [ "yes" != "${FLAGBOOLS[$key]}" ]; then
				next=$(( next + 1 ))
			fi
			break
		done
		if (( 0 == $next )); then
			rest="$rest $1"
			shift
		else
			shift $next
		fi
	done
	echo "$rest"
}

function usage() {
	echo "Usage: $0 OPTIONS"
	echo "Options:"
	for flag in "${!FLAGBOOLS[@]}"; do
		echo -en "\t$flag: ${FLAGBOOLS[$flag]} "
		if ! [ -z "${FLAGDFLTS[$flag]}" ]; then
			echo -n "(default: ${FLAGDFLTS[$flag]})"
		fi
		echo
		echo -e "\t\t${FLAGDESCS[$flag]}"
	done
	echo -e "$1"
}
