case $( uname -s ) in
'Linux')
	get_date () {
		date --utc "$@" || return 0
	}
	;;
*)
	get_date () {
		gdate --utc "$@" || return 0
	}
esac


get_current_time () {
	get_date '+%s' "$@" || return 0
}


get_http_date () {
	get_date --rfc-2822 "$@" || return 0
}
