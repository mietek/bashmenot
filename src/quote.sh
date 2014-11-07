case $( detect_os ) in
'linux-'*)
	sed_unbuffered () {
		sed -u "$@" || return 0
	}
	;;
'osx-'*)
	sed_unbuffered () {
		sed -l "$@" || return 0
	}
	;;
*)
	sed_unbuffered () {
		sed "$@" || return 0
	}
esac


quote () {
	sed_unbuffered 's/^/       /' >&2 || return 0
}
