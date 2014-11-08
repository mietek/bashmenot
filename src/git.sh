get_git_commit_hash () {
	local dir
	expect_args dir -- "$@"
	expect_existing "${dir}"

	( cd "${dir}" && git log -n 1 --pretty='format:%h' ) || return 1
}


git_quiet () {
	local cmd
	expect_args cmd -- "$@"
	shift

	git "${cmd}" -q "$@" &>'/dev/null' || return 1
}


git_clone_over () {
	local urloid dir
	expect_args urloid dir -- "$@"

	rm -rf "${dir}" || return 1
	mkdir -p "${dir}" || return 1

	local url branchoid
	url="${urloid%#*}"
	branchoid="${urloid#*#}"
	if [[ "${branchoid}" == "${url}" ]]; then
		branchoid='master';
	fi

	git_quiet clone "${url}" "${dir}" || return 1
	(
		cd "${dir}" &&
		git_quiet checkout "${branchoid}" &&
		git_quiet submodule update --init --recursive
	) || return 1

	get_git_commit_hash "${dir}" || return 1
}


git_update_into () {
	local urloid dir
	expect_args urloid dir -- "$@"
	expect_existing "${dir}"

	local url branchoid
	url="${urloid%#*}"
	branchoid="${urloid#*#}"
	if [[ "${branchoid}" == "${url}" ]]; then
		branchoid='master';
	fi

	local old_url
	old_url=$( cd "${dir}" && git config --get 'remote.origin.url' ) || return 1
	if [[ "${old_url}" != "${url}" ]]; then
		( cd "${dir}" && git remote set-url 'origin' "${url}" ) || return 1
	fi

	(
		cd "${dir}" &&
		git_quiet fetch 'origin' &&
		git_quiet fetch --tags 'origin' &&
		git_quiet reset --hard "origin/${branchoid}" &&
		git_quiet submodule update --init --recursive
	) || return 1

	get_git_commit_hash "${dir}" || return 1
}
