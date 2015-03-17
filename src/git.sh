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


git_do () {
	local work_dir cmd
	expect_args work_dir cmd -- "$@"
	shift 2

	expect_existing "${work_dir}" || return 1

	(
		cd "${work_dir}" &&
		git "${cmd}" "$@"
	) || return 1
}


quiet_git_do () {
	local work_dir cmd
	expect_args work_dir cmd -- "$@"
	shift 2

	expect_existing "${work_dir}" || return 1

	git_do "${work_dir}" "${cmd}" "$@" >'/dev/null' 2>&1 || return 1
}


hash_newest_git_commit () {
	local dir
	expect_args dir -- "$@"

	expect_existing "${dir}" || return 1

	local commit_hash
	if ! commit_hash=$( git_do "${dir}" log -n 1 --pretty='format:%h' 2>'/dev/null' ); then
		return 0
	fi

	echo "${commit_hash}"
}


git_clone_over () {
	local url dir
	expect_args url dir -- "$@"

	local work_dir base_url branch
	work_dir=$( dirname "${dir}" ) || return 1
	base_url="${url%#*}"
	branch="${url#*#}"
	if [[ "${branch}" == "${base_url}" ]]; then
		branch='master';
	fi

	rm -rf "${dir}" || return 1
	mkdir -p "${work_dir}" || return 1
	quiet_git_do "${work_dir}" clone "${base_url}" "${dir}" || return 1

	local commit_hash
	commit_hash=$( hash_newest_git_commit "${dir}" ) || return 1
	if [[ -n "${commit_hash}" ]]; then
		quiet_git_do "${dir}" checkout "${branch}" || return 1
		quiet_git_do "${dir}" submodule update --init --recursive || return 1
	fi

	hash_newest_git_commit "${dir}" || return 1
}


git_update_into () {
	local url dir
	expect_args url dir -- "$@"

	expect_existing "${dir}" || return 1

	local base_url branch
	base_url="${url%#*}"
	branch="${url#*#}"
	if [[ "${branch}" == "${base_url}" ]]; then
		branch='master';
	fi

	local old_url
	old_url=$( git_do "${dir}" config --get 'remote.origin.url' ) || return 1
	if [[ "${old_url}" != "${base_url}" ]]; then
		git_do "${dir}" remote set-url 'origin' "${base_url}" || return 1
	fi

	quiet_git_do "${dir}" fetch 'origin' || return 1
	quiet_git_do "${dir}" fetch --tags 'origin' || return 1
	quiet_git_do "${dir}" reset --hard "origin/${branch}" || return 1
	quiet_git_do "${dir}" submodule update --init --recursive || return 1

	hash_newest_git_commit "${dir}" || return 1
}


git_acquire () {
	local src_dir thing dst_dir
	expect_args src_dir thing dst_dir -- "$@"

	local name
	if validate_git_url "${thing}"; then
		name=$( basename "${thing%.git}" ) || return 1

		local commit_hash
		if [[ ! -d "${dst_dir}/${name}" ]]; then
			log_begin "Cloning ${thing}..."

			if ! commit_hash=$( git_clone_over "${thing}" "${dst_dir}/${name}" ); then
				log_end 'error'
				return 1
			fi
		else
			log_begin "Updating ${thing}..."

			if ! commit_hash=$( git_update_into "${thing}" "${dst_dir}/${name}" ); then
				log_end 'error'
				return 1
			fi
		fi
		log_end "done, ${commit_hash}"
	else
		name=$( get_dir_name "${src_dir}/${thing}" ) || return 1

		copy_dir_over "${src_dir}/${thing}" "${dst_dir}/${name}" || return 1
	fi

	echo "${name}"
}


git_acquire_all () {
	local src_dir things dst_dir
	expect_args src_dir things dst_dir -- "$@"

	if [[ -z "${things}" ]]; then
		return 0
	fi

	local -a names_a
	local thing
	names_a=()
	while read -r thing; do
		local name
		name=$( git_acquire "${src_dir}" "${thing}" "${dst_dir}" ) || return 1
		names_a+=( "${name}" )
	done <<<"${things}"

	IFS=$'\n' && echo "${names_a[*]}"
}
