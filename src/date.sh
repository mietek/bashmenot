case $( uname -s ) in
'Linux'|'FreeBSD')
	get_date () {
		date -u "$@" || return 0
	}
	;;
*)
	get_date () {
		gdate -u "$@" || return 0
	}
esac


get_http_date () {
	get_date -R "$@" || return 0
}


get_current_time () {
	get_date '+%s' "$@" || return 0
}
