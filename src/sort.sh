case "$( detect_os )" in
'linux-'*)
	function sort_naturally () {
		sort -V "$@" || true
	}
	;;
*)
	function sort_naturally () {
		gsort -V "$@" || true
	}
esac


function sort0_naturally () {
	sort_naturally -z "$@" || true
}
