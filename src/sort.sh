case $( uname -s ) in
'Linux')
	sort_natural () {
		sort -V "$@" || true
	}
	;;
*)
	sort_natural () {
		gsort -V "$@" || true
	}
esac


sort0_natural () {
	sort_natural -z "$@" || true
}
