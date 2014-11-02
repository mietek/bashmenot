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


log_debug () {
	prefix_log '   *** DEBUG: ' "$@"
}


log_warning () {
	prefix_log '   *** WARNING: ' "$@"
}


log_error () {
	prefix_log '   *** ERROR: ' "$@"
}


log_delimiter () {
	echo '-----------------------------------------------------------------------------' >&2
}


log_pad () {
	local thing
	thing="$1$( printf ' %.0s' {0..41} )"
	shift

	log "${thing:0:41}" "$@"
}


log_indent_pad () {
	local thing
	thing="$1$( printf ' %.0s' {0..41} )"
	shift

	log_indent "${thing:0:41}" "$@"
}


die () {
	if [[ -n "${*:+_}" ]]; then
		log_error "$@"
	fi
	exit 1
}
