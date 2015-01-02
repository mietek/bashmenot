expect_args () {
	local -a specs_a
	local status
	status=1
	while (( $# )); do
		if [[ "$1" == -- ]]; then
			status=0
			shift
			break
		fi
		specs_a+=( "$1" )
		shift
	done
	if (( status )); then
		die "${FUNCNAME[1]:--}: Expected specs, guard, and args:" 'arg1 .. argN -- "$@"'
	fi

	local spec
	for spec in "${specs_a[@]}"; do
		if ! (( $# )); then
			die "${FUNCNAME[1]:--}: Expected args: ${specs_a[*]:-}"
		fi
		eval "${spec}=\$1"
		shift
	done
}


expect_vars () {
	while (( $# )); do
		if [[ -z "${!1:+_}" ]]; then
			die "${FUNCNAME[1]:--}: Expected var: $1"
		fi
		shift
	done
}


expect_existing () {
	while (( $# )); do
		if [[ ! -e "$1" ]]; then
			die "${FUNCNAME[1]:--}: Expected existing $1"
		fi
		shift
	done
}


expect_no_existing () {
	while (( $# )); do
		if [[ -e "$1" ]]; then
			die "${FUNCNAME[1]:--}: Unexpected existing $1"
		fi
		shift
	done
}
