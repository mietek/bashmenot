get_hash () {
	local input
	input=$( cat ) || true

	if [[ -z "${input}" ]]; then
		return 0
	fi

	openssl sha1 <<<"${input}" |
		sed 's/^.* //' || return 1
}


hash_tree () {
	local dir
	expect_args dir -- "$@"
	shift

	if [[ ! -d "${dir}" ]]; then
		return 0
	fi

	(
		cd "${dir}" &&
		find '.' "$@" -type f -exec openssl sha1 '{}' ';' 2>'/dev/null'
	) |
		sort_natural |
		get_hash || return 1
}
