case "$( detect_os )" in
'linux-'*)
	function sort_naturally () {
		sort -V "$@" || return 0
	}
	;;
*)
	function sort_naturally () {
		gsort -V "$@" || return 0
	}
esac


function sort0_naturally () {
	sort_naturally -z "$@" || return 0
}
