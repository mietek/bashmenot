prefix_log () {
	local prefix
	prefix="$1"
	shift

	echo "${*:+${prefix}$*}" >&2
}


prefix_log_begin () {
	local prefix
	prefix="$1"
	shift

	echo -n "${*:+${prefix}$* }" >&2
}


log () {
	prefix_log '-----> ' "$@"
}


log_begin () {
	prefix_log_begin '-----> ' "$@"
}


log_end () {
	prefix_log '' "$@"
}


log_indent () {
	prefix_log '       ' "$@"
}


log_indent_begin () {
	prefix_log_begin '       ' "$@"
}


log_label () {
	local label
	label="$1$( printf ' %.0s' {0..41} )"
	shift

	log "${label:0:41}" "$@"
}


log_indent_label () {
	local label
	label="$1$( printf ' %.0s' {0..41} )"
	shift

	log_indent "${label:0:41}" "$@"
}


log_debug () {
	prefix_log '   *** DEBUG: ' "$@"
}


log_warning () {
	prefix_log '   *** WARNING: ' "$@"
}


log_error () {
	prefix_log '   *** ERROR: ' "$@"
}


die () {
	if [[ -n "${*:+_}" ]]; then
		log_error "$@"
	fi
	exit 1
}
