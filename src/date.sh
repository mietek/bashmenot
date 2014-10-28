case "$( detect_os )" in
'linux-'*)
	function format_http_date () {
		date --utc --rfc-2822 "$@" || die
	}
	;;
*)
	function format_http_date () {
		gdate --utc --rfc-2822 "$@" || die
	}
esac


case "$( detect_os )" in
'linux-'*)
	function format_date () {
		date --utc +'%Y-%m-%d' "$@" || die
	}
	;;
*)
	function format_date () {
		gdate --utc +'%Y-%m-%d' "$@" || die
	}
esac
