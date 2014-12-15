case $( uname -s ) in
'Linux')
	get_date () {
		date --utc "$@" || true
	}
	;;
*)
	get_date () {
		gdate --utc "$@" || true
	}
esac


get_current_time () {
	get_date '+%s' "$@" || true
}


get_http_date () {
	get_date --rfc-2822 "$@" || true
}
