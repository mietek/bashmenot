hash_last_git_commit () {
	local dir
	expect_args dir -- "$@"
	expect_existing "${dir}"

	( cd "${dir}" && git log -n 1 --pretty='format:%H' )
}


git_quiet () {
	local cmd
	expect_args cmd -- "$@"
	shift

	git "${cmd}" -q "$@" &>'/dev/null'
}


git_clone_over () {
	local url dir
	expect_args url dir -- "$@"

	rm -rf "${dir}" || return 1
	mkdir -p "${dir}" || return 1

	local bare_url branch
	bare_url="${url%#*}"
	branch="${url#*#}"
	if [[ "${branch}" == "${bare_url}" ]]; then
		branch='master';
	fi

	git_quiet clone "${bare_url}" "${dir}" || return 1
	(
		cd "${dir}" &&
		git_quiet checkout "${branch}" &&
		git_quiet submodule update --init --recursive
	) || return 1

	hash_last_git_commit "${dir}"
}


git_update_into () {
	local url dir
	expect_args url dir -- "$@"
	expect_existing "${dir}"

	local bare_url branch
	bare_url="${url%#*}"
	branch="${url#*#}"
	if [[ "${branch}" == "${bare_url}" ]]; then
		branch='master';
	fi

	local old_url
	old_url=$( cd "${dir}" && git config --get 'remote.origin.url' ) || return 1
	if [[ "${old_url}" != "${bare_url}" ]]; then
		( cd "${dir}" && git remote set-url 'origin' "${bare_url}" ) || return 1
	fi

	(
		cd "${dir}" &&
		git_quiet fetch 'origin' &&
		git_quiet fetch --tags 'origin' &&
		git_quiet reset --hard "origin/${branch}" &&
		git_quiet submodule update --init --recursive
	) || return 1

	hash_last_git_commit "${dir}"
}
