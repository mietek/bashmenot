case "$( detect_os )" in
'linux-'*)
	function sed_unbuffered () {
		sed -u "$@" || true
	}
	;;
'os-x-'*)
	function sed_unbuffered () {
		sed -l "$@" || true
	}
	;;
*)
	function sed_unbuffered () {
		sed "$@" || true
	}
esac


function quote () {
	sed_unbuffered 's/^/       /' >&2 || true
}
