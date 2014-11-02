case $( detect_os ) in
'linux-'*)
	format_http_date () {
		date --utc --rfc-2822 "$@" || die
	}
	;;
*)
	format_http_date () {
		gdate --utc --rfc-2822 "$@" || die
	}
esac


case $( detect_os ) in
'linux-'*)
	format_date () {
		date --utc +'%Y-%m-%d' "$@" || die
	}
	;;
*)
	format_date () {
		gdate --utc +'%Y-%m-%d' "$@" || die
	}
esac
