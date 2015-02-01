case $( uname -s ) in
'Linux'|'FreeBSD')
	sort_do () {
		sort "$@" || return 0
	}
	;;
*)
	sort_do () {
		gsort "$@" || return 0
	}
esac


sort_natural () {
	sort_do -V "$@" || return 0
}


sort0_natural () {
	sort_do -Vz "$@" || return 0
}
