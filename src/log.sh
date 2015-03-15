bashmenot_internal_get_timestamp () {
	if (( ${BASHMENOT_LOG_TIMESTAMP:-0} )); then
		if [[ -z "${BASHMENOT_TIMESTAMP_EPOCH:-}" ]]; then
			local now
			now=$( get_date '+%H:%M:%S' )

			echo -e "\033[2m${now}\033[0m "
		else
			local now diff pad
			now=$( get_current_time )
			diff=$(( now - BASHMENOT_TIMESTAMP_EPOCH ))
			pad='          '

			echo -e "\033[2m${pad:0:$(( 10 - ${#diff} ))}${diff}\033[0m "
		fi
	fi
}


bashmenot_internal_get_empty_timestamp () {
	if (( ${BASHMENOT_LOG_TIMESTAMP:-0} )); then
		if [[ -z "${BASHMENOT_TIMESTAMP_EPOCH:-}" ]]; then
			echo '         '
		else
			echo '           '
		fi
	fi
}


prefix_log () {
	local now prefix
	now=$( bashmenot_internal_get_timestamp )
	prefix="$1"
	shift

	echo "${now}${*:+${prefix}$*}" >&2
}


prefix_log_begin () {
	local now prefix
	now=$( bashmenot_internal_get_timestamp )
	prefix="$1"
	shift

	printf -- "${now}${*:+${prefix}$* }" >&2
}


log () {
	prefix_log '-----> ' "$@"
}


log_begin () {
	prefix_log_begin '-----> ' "$@"
}


log_end () {
	echo "$@" >&2
}


log_indent () {
	prefix_log '       ' "$@"
}


log_indent_begin () {
	prefix_log_begin '       ' "$@"
}


log_indent_end () {
	echo "$@" >&2
}


log_label () {
	local label
	label="$1$( printf ' %.0s' {0..41} )"
	shift

	log "${label:0:41}" "$( echo -en '\033[1m' )$*$( echo -en '\033[0m' )"
}


log_indent_label () {
	local label
	label="$1$( printf ' %.0s' {0..41} )"
	shift

	log_indent "${label:0:41}" "$( echo -en '\033[1m' )$*$( echo -en '\033[0m' )"
}


log_debug () {
	prefix_log "$( echo -en '\033[1m' )   *** DEBUG: " "$*$( echo -en '\033[0m' )"
}


log_warning () {
	prefix_log "$( echo -en '\033[1m' )   *** WARNING: " "$*$( echo -en '\033[0m' )"
}


log_error () {
	prefix_log "$( echo -en '\033[1m' )   *** ERROR: " "$*$( echo -en '\033[0m' )"
}


case $( uname -s ) in
'Linux')
	quote () {
		local prefix
		prefix="$( bashmenot_internal_get_empty_timestamp )       "

		sed -u "s/^/${prefix}/" >&2 || return 0
	}
	;;
'Darwin')
	quote () {
		local prefix
		prefix="$( bashmenot_internal_get_empty_timestamp )       "

		sed -l "s/^/${prefix}/" >&2 || return 0
	}
	;;
*)
	quote () {
		local prefix
		prefix="$( bashmenot_internal_get_empty_timestamp )       "

		sed "s/^/${prefix}/" >&2 || return 0
	}
esac


die () {
	if [[ -n "${*:+_}" ]]; then
		log_error "$@"
	fi

	exit 1
}
