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
	prefix_log '-----> ' "$@" || true
}


log_begin () {
	prefix_log_begin '-----> ' "$@" || true
}


log_end () {
	prefix_log '' "$@" || true
}


log_indent () {
	prefix_log '       ' "$@" || true
}


log_indent_begin () {
	prefix_log_begin '       ' "$@" || true
}


log_label () {
	local label
	label="$1$( printf ' %.0s' {0..41} )" || true
	shift

	log "${label:0:41}" "$@" || true
}


log_indent_label () {
	local label
	label="$1$( printf ' %.0s' {0..41} )" || true
	shift

	log_indent "${label:0:41}" "$@" || true
}


log_debug () {
	prefix_log '   *** DEBUG: ' "$@" || true
}


log_warning () {
	prefix_log '   *** WARNING: ' "$@" || true
}


log_error () {
	prefix_log '   *** ERROR: ' "$@" || true
}


die () {
	if [[ -n "${*:+_}" ]]; then
		log_error "$@" || true
	fi
	
	exit 1
}
