case "$( detect_os )" in
'linux-'*)
	function sort_natural () {
		sort -V "$@" || return 0
	}
	;;
*)
	function sort_natural () {
		gsort -V "$@" || return 0
	}
esac


function sort0_natural () {
	sort_natural -z "$@" || return 0
}
