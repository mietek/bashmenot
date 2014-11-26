case $( detect_os ) in
'linux')
	get_http_date () {
		date --utc --rfc-2822 "$@"
	}

	get_iso_date () {
		date --utc +'%Y-%m-%d' "$@"
	}
	;;
*)
	get_http_date () {
		gdate --utc --rfc-2822 "$@"
	}

	get_iso_date () {
		gdate --utc +'%Y-%m-%d' "$@"
	}
esac
