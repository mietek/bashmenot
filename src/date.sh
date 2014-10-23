case "$( detect_os )" in
'linux-'*)
	function format_date () {
		date "$@" || die
	}
	;;
*)
	function format_date () {
		gdate "$@" || die
	}
esac


function format_http_date () {
	format_date --utc --rfc-2822 "$@" || die
}


function format_timestamp () {
	format_date --utc +'%Y%m%d%H%M%S' "$@" || die
}


function get_timestamp_date () {
	local timestamp
	expect_args timestamp -- "$@"

	echo "${timestamp:0:4}-${timestamp:4:2}-${timestamp:6:2}"
}


function get_timestamp_time () {
	local timestamp
	expect_args timestamp -- "$@"

	echo "${timestamp:8:2}:${timestamp:10:2}:${timestamp:12:2}"
}
