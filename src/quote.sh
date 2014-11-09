case $( detect_os ) in
'linux-'*)
	quote () {
		sed -u 's/^/       /' >&2 || true
	}
	;;
'osx-'*)
	quote () {
		sed -l 's/^/       /' >&2 || true
	}
	;;
*)
	quote () {
		sed 's/^/       /' >&2 || true
	}
esac
