hash_newest_git_commit () {
	local dir
	expect_args dir -- "$@"
	expect_existing "${dir}"

	local commit_hash
	if ! commit_hash=$(
		cd "${dir}" &&
		git log -n 1 --pretty='format:%H' 2>'/dev/null'
	); then
		echo 'empty'
		return 0
	fi

	echo "${commit_hash}"
}


validate_git_url () {
	local url
	expect_args url -- "$@"

	case "${url}" in
	'https://'*);&
	'ssh://'*);&
	'git@'*);&
	'file://'*);&
	'http://'*);&
	'git://'*)
		return 0
		;;
	*)
		return 1
	esac
}


quiet_git_do () {
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

	quiet_git_do clone "${bare_url}" "${dir}" || return 1

	local commit_hash
	commit_hash=$( hash_newest_git_commit "${dir}" ) || return 1

	if [[ "${commit_hash}" != 'empty' ]]; then
		(
			cd "${dir}" &&
			quiet_git_do checkout "${branch}" &&
			quiet_git_do submodule update --init --recursive
		) || return 1
	fi

	hash_newest_git_commit "${dir}"
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
		quiet_git_do fetch 'origin' &&
		quiet_git_do fetch --tags 'origin' &&
		quiet_git_do reset --hard "origin/${branch}" &&
		quiet_git_do submodule update --init --recursive
	) || return 1

	hash_newest_git_commit "${dir}"
}
