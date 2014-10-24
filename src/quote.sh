case "$( detect_os )" in
'linux-'*)
	function sed_unbuffered () {
		sed -u "$@" || return 0
	}
	;;
'os-x-'*)
	function sed_unbuffered () {
		sed -l "$@" || return 0
	}
	;;
*)
	function sed_unbuffered () {
		sed "$@" || return 0
	}
esac


function quote () {
	sed_unbuffered 's/^/       /' >&2 || return 0
}
