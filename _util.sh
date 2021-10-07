function random-name() {
	cat /dev/random | tr -cd 'a-z0-9' | head -c${1:-"12"}
}

function random-port() {
	shuf -i 3333-9999 -n1
}

function copy-to-clipboard() {
	$( [[ $(uname -a) =~ Microsoft ]] && "clip.exe" || "xclip -sel c" )
}
function get-python {
	which python3 || which python
}

