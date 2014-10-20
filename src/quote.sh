case "$( detect_os )" in
'linux-'*)
	function sed_unbuffered () {
		sed -u "$@"
	}
	;;
'os-x-'*)
	function sed_unbuffered () {
		sed -l "$@"
	}
	;;
*)
	function sed_unbuffered () {
		sed "$@"
	}
esac


function quote () {
	sed_unbuffered 's/^/       /' >&2
}
