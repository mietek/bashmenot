expect_args () {
	local -a expect_internal_specs_a
	local expect_internal_status
	expect_internal_status=1
	while (( $# )); do
		if [[ "$1" == -- ]]; then
			expect_internal_status=0
			shift
			break
		fi
		expect_internal_specs_a+=( "$1" )
		shift
	done
	if (( expect_internal_status )); then
		die "${FUNCNAME[1]:--}: Expected specs, guard, and args:" 'arg1 .. argN -- "$@"'
	fi

	local expect_internal_spec
	for expect_internal_spec in "${expect_internal_specs_a[@]}"; do
		if ! (( $# )); then
			die "${FUNCNAME[1]:--}: Expected args: ${expect_internal_specs_a[*]:-}"
		fi
		eval "${expect_internal_spec}=\$1"
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
			log_error "${FUNCNAME[1]:--}: Expected existing $1"
			return 1
		fi
		shift
	done
}


expect_no_existing () {
	while (( $# )); do
		if [[ -e "$1" ]]; then
			log_error "${FUNCNAME[1]:--}: Unexpected existing $1"
			return 1
		fi
		shift
	done
}
