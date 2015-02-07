get_tmp_file () {
	local base
	expect_args base -- "$@"

	local template
	if [[ -z "${BASHMENOT_INTERNAL_TMP:-}" ]]; then
		template="/tmp/${base}.XXXXXXXXXX"
	else
		template="${BASHMENOT_INTERNAL_TMP}/${base}.XXXXXXXXXX"
	fi

	local tmp_file
	if ! tmp_file=$( mktemp -u "${template}" ); then
		log_error 'Failed to create temporary file'
		return 1
	fi

	echo "${tmp_file}"
}


get_tmp_dir () {
	local base
	expect_args base -- "$@"

	local template
	if [[ -z "${BASHMENOT_INTERNAL_TMP:-}" ]]; then
		template="/tmp/${base}.XXXXXXXXXX"
	else
		template="${BASHMENOT_INTERNAL_TMP}/${base}.XXXXXXXXXX"
	fi

	local tmp_dir
	if ! tmp_dir=$( mktemp -du "${template}" ); then
		log_error 'Failed to create temporary directory'
		return 1
	fi

	echo "${tmp_dir}"
}


get_size () {
	local thing
	expect_args thing -- "$@"

	du -sh "${thing}" |
		awk '{ print $1 }' |
		sed 's/K$/KB/;s/M$/MB/;s/G$/GB/' || return 1
}


case $( uname -s ) in
'Linux')
	get_modification_time () {
		local thing
		expect_args thing -- "$@"

		stat -c "%Y" "${thing}" || return 1
	}
	;;
*)
	get_modification_time () {
		local thing
		expect_args thing -- "$@"

		stat -f "%m" "${thing}" || return 1
	}
esac


get_dir_path () {
	local dir
	expect_args dir -- "$@"

	expect_existing "${dir}" || return 1

	( cd "${dir}" && pwd -P ) || return 1
}


get_dir_name () {
	local dir
	expect_args dir -- "$@"

	expect_existing "${dir}" || return 1

	local path
	path=$( get_dir_path "${dir}" ) || return 1

	basename "${path}" || return 1
}


# TODO: Use realpath instead of readlink.
case $( uname -s ) in
'Linux')
	get_link_path () {
		local link
		expect_args link -- "$@"

		readlink -m "${link}" || return 1
	}
	;;
*)
	get_link_path () {
		local link
		expect_args link -- "$@"

		greadlink -m "${link}" || return 1
	}
esac


find_tree () {
	local dir
	expect_args dir -- "$@"
	shift

	if [[ ! -d "${dir}" ]]; then
		return 0
	fi

	( cd "${dir}" && find '.' "$@" 2>'/dev/null' ) |
		sed 's:^\./::' || return 0
}


find_added () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	local new_file
	find "${new_dir}" "$@" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"

			if [[ ! -f "${old_file}" ]]; then
				echo "${path}"
			fi
		done || return 0
}


find_changed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	local new_file
	find "${new_dir}" "$@" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"

			if [[ -f "${old_file}" ]] && ! cmp -s "${old_file}" "${new_file}"; then
				echo "${path}"
			fi
		done || return 0
}


find_not_changed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	local new_file
	find "${new_dir}" "$@" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"

			if [[ -f "${old_file}" ]] && cmp -s "${old_file}" "${new_file}"; then
				echo "${path}"
			fi
		done || return 0
}


find_removed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	local old_file
	find "${old_dir}" "$@" -type f -print0 2>'/dev/null' |
		sort0_natural |
		while read -rd $'\0' old_file; do
			local path new_file
			path="${old_file##${old_dir}/}"
			new_file="${new_dir}/${path}"

			if [[ ! -f "${new_file}" ]]; then
				echo "${path}"
			fi
		done || return 0
}


compare_tree () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"
	shift 2

	(
		find_added "${old_dir}" "${new_dir}" "$@" | sed 's/^/+ /'
		find_changed "${old_dir}" "${new_dir}" "$@" | sed 's/^/* /'
		find_not_changed "${old_dir}" "${new_dir}" "$@" | sed 's/^/= /'
		find_removed "${old_dir}" "${new_dir}" "$@" | sed 's/^/- /'
	) |
		sort_do -k 2 || return 0
}


expand_glob () {
	local dir glob
	expect_args dir glob -- "$@"

	expect_existing "${dir}" || return 1

	# TODO: Use $'\0' as delimiter.

	(
		local -a files_a
		cd "${dir}" &&
			IFS=$'\n' && files_a=( ${glob} ) &&
			echo "${files_a[*]}"
	) || return 1
}
