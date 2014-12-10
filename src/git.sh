hash_newest_git_commit () {
	local dir
	expect_args dir -- "$@"
	expect_existing "${dir}"

	local commit_hash
	if ! commit_hash=$(
		cd "${dir}" &&
		git log -n 1 --pretty='format:%H' 2>'/dev/null'
	); then
		return 0
	fi

	echo "${commit_hash}"
}


validate_git_url () {
	local url
	expect_args url -- "$@"

	case "${url}" in
	'https://'*)	return 0;;
	'ssh://'*)	return 0;;
	'git@'*)	return 0;;
	'file://'*)	return 0;;
	'http://'*)	return 0;;
	'git://'*)	return 0;;
	*)		return 1
	esac
}


quiet_git_do () {
	local cmd
	expect_args cmd -- "$@"
	shift

	git "${cmd}" -q "$@" >'/dev/null' 2>&1
}


git_clone_over () {
	local url dir
	expect_args url dir -- "$@"

	rm -rf "${dir}" || return 1
	mkdir -p "${dir}" || return 1

	local base_url branch
	base_url="${url%#*}"
	branch="${url#*#}"
	if [[ "${branch}" == "${base_url}" ]]; then
		branch='master';
	fi

	quiet_git_do clone "${base_url}" "${dir}" || return 1

	local commit_hash
	commit_hash=$( hash_newest_git_commit "${dir}" ) || return 1
	if [[ -n "${commit_hash}" ]]; then
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

	local base_url branch
	base_url="${url%#*}"
	branch="${url#*#}"
	if [[ "${branch}" == "${base_url}" ]]; then
		branch='master';
	fi

	local old_url
	old_url=$( cd "${dir}" && git config --get 'remote.origin.url' ) || return 1
	if [[ "${old_url}" != "${base_url}" ]]; then
		( cd "${dir}" && git remote set-url 'origin' "${base_url}" ) || return 1
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


git_over_here () {
	local thing dst_dir
	expect_args thing dst_dir -- "$@"

	local name
	name=$( basename "${thing%.git}" ) || return 1

	if validate_git_url "${thing}"; then
		local commit_hash
		if [[ ! -d "${dst_dir}/${name}" ]]; then
			log_indent_begin "Cloning ${thing}..."

			if ! commit_hash=$( git_clone_over "${thing}" "${dst_dir}/${name}" ); then
				log_indent_end 'error'
				return 1
			fi
		else
			log_indent_begin "Updating ${thing}..."

			if ! commit_hash=$( git_update_into "${thing}" "${dst_dir}/${name}" ); then
				log_indent_end 'error'
				return 1
			fi
		fi
		log_indent_end "done, ${commit_hash:0:7}"
	else
		log_indent "Copying ${thing}"

		copy_dir_over "${thing}" "${dst_dir}/${name}" || return 1
	fi

	echo "${name}"
}


git_all_over_here () {
	local all_things dst_dir
	expect_args all_things dst_dir -- "$@"

	local -a things
	things=( ${all_things} )
	if [[ -z "${things[@]:+_}" ]]; then
		return 0
	fi

	local thing
	for thing in "${things[@]}"; do
		git_over_here "${thing}" "${dst_dir}" || return 1
	done
}
