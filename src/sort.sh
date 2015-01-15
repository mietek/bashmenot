case $( uname -s ) in
'Linux'|'FreeBSD')
	sort_natural () {
		sort -V "$@" || return 0
	}
	;;
*)
	sort_natural () {
		gsort -V "$@" || return 0
	}
esac


sort0_natural () {
	sort_natural -z "$@" || return 0
}
