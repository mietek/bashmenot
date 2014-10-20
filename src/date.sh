case "$( detect_os )" in
'linux-'*)
	function echo_date () {
		date "$@" || die
	}
	;;
*)
	function echo_date () {
		gdate "$@" || die
	}
esac


function echo_http_date () {
	echo_date --utc --rfc-2822 "$@" || die
}


function echo_timestamp () {
	echo_date --utc +'%Y%m%d%H%M%S' "$@" || die
}
