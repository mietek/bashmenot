get_tmp_file () {
	local base
	expect_args base -- "$@"

	mktemp -u "/tmp/${base}.XXXXXXXXXX" || false
}


get_tmp_dir () {
	local base
	expect_args base -- "$@"

	mktemp -du "/tmp/${base}.XXXXXXXXXX" || false
}


get_size () {
	local thing
	expect_args thing -- "$@"

	du -sh "${thing}" |
		awk '{ print $1 }' |
		sed 's/K$/KB/;s/M$/MB/;s/G$/GB/' || false
}


case $( detect_os ) in
'linux')
	get_modification_time () {
		local thing
		expect_args thing -- "$@"

		stat -c "%Y" "${thing}" || false
	}
	;;
*)
	get_modification_time () {
		local thing
		expect_args thing -- "$@"

		stat -f "%m" "${thing}" || false
	}
esac


get_dir_path () {
	local dir
	expect_args dir -- "$@"
	expect_existing "${dir}"

	( cd "${dir}" && pwd -P ) || false
}


get_dir_name () {
	local dir
	expect_args dir -- "$@"
	expect_existing "${dir}"

	local path
	path=$( get_dir_path "${dir}" ) || false

	basename "${path}" || false
}


find_tree () {
	local dir
	expect_args dir -- "$@"
	shift

	if [[ ! -d "${dir}" ]]; then
		return 0
	fi

	( cd "${dir}" && find '.' "$@" 2>'/dev/null' ) |
		sed 's:^\./::' || true
}


find_added () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	local new_file
	find "${new_dir}" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"

			if [[ ! -f "${old_file}" ]]; then
				echo "${path}"
			fi
		done || true
}


find_changed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	local new_file
	find "${new_dir}" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"

			if [[ -f "${old_file}" ]] && ! cmp -s "${old_file}" "${new_file}"; then
				echo "${path}"
			fi
		done || true
}


find_not_changed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	local new_file
	find "${new_dir}" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"

			if [[ -f "${old_file}" ]] && cmp -s "${old_file}" "${new_file}"; then
				echo "${path}"
			fi
		done || true
}


find_removed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	local old_file
	find "${old_dir}" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' old_file; do
			local path new_file
			path="${old_file##${old_dir}/}"
			new_file="${new_dir}/${path}"

			if [[ ! -f "${new_file}" ]]; then
				echo "${path}"
			fi
		done || true
}


compare_tree () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	(
		find_added "${old_dir}" "${new_dir}" | sed 's/$/ +/'
		find_changed "${old_dir}" "${new_dir}" | sed 's/$/ */'
		find_not_changed "${old_dir}" "${new_dir}" | sed 's/$/ =/'
		find_removed "${old_dir}" "${new_dir}" | sed 's/$/ -/'
	) |
		sort_natural |
		awk '{ print $2 " " $1 }' || true
}
