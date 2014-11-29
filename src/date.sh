case $( uname -s ) in
'Linux')
	get_http_date () {
		date --utc --rfc-2822 "$@"
	}

	get_date () {
		date --utc "$@"
	}
	;;
*)
	get_http_date () {
		gdate --utc --rfc-2822 "$@"
	}

	get_date () {
		gdate --utc "$@"
	}
esac
