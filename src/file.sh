get_tmp_file () {
	local base
	expect_args base -- "$@"

	mktemp -u "/tmp/${base}.XXXXXXXXXX" || die
}


get_tmp_dir () {
	local base
	expect_args base -- "$@"

	mktemp -du "/tmp/${base}.XXXXXXXXXX" || die
}


get_size () {
	local thing
	expect_args thing -- "$@"

	du -sh "${thing}" |
		awk '{ print $1 }' |
		sed 's/K$/KB/;s/M$/MB/;s/G$/GB/' || die
}


case $( detect_os ) in
'linux-'*)
	get_modification_time () {
		local thing
		expect_args thing -- "$@"

		stat -c "%Y" "${thing}" || die
	}
	;;
*)
	get_modification_time () {
		local thing
		expect_args thing -- "$@"

		stat -f "%m" "${thing}" || die
	}
esac


get_dir_path () {
	local dir
	expect_args dir -- "$@"

	( cd "${dir}" && pwd -P ) || die
}


get_dir_name () {
	local dir
	expect_args dir -- "$@"

	local path
	path=$( get_dir_path "${dir}" ) || die

	basename "${path}" || die
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
		done || return 0
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
		done || return 0
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
		done || return 0
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
		done || return 0
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
		awk '{ print $2 " " $1 }' || return 0
}


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


do_hash () {
	local input
	input=$( cat ) || die

	if [[ -z "${input}" ]]; then
		return 0
	fi

	openssl sha1 <<<"${input}" |
		sed 's/^.* //' || die
}


hash_tree () {
	local dir
	expect_args dir -- "$@"
	shift

	if [[ ! -d "${dir}" ]]; then
		return 0
	fi

	( cd "${dir}" && find '.' "$@" -type f -exec openssl sha1 '{}' ';' 2>'/dev/null' ) |
		sort_natural |
		do_hash || return 0
}


case $( detect_os ) in
'linux-'*)
	strip_tree () {
		local dir
		expect_args dir -- "$@"

		local file
		find "${dir}" "$@" -type f -print0 2>'/dev/null' |
			sort0_natural |
			while read -rd $'\0' file; do
				strip --strip-unneeded "${file}" 2>'/dev/null' | quote || true
			done || return 0
	}
	;;
'osx-'*)
	strip_tree () {
		local dir
		expect_args dir -- "$@"

		local file
		find "${dir}" "$@" -type f -print0 2>'/dev/null' |
			sort0_natural |
			while read -rd $'\0' file; do
				strip -u -r "${file}" 2>'/dev/null' | quote || true
			done || return 0
	}
	;;
*)
	strip_tree () {
		log_warning 'Stripping is unsupported on this OS'
		return 0
	}
esac


copy_file () {
	local src_file dst_file
	expect_args src_file dst_file -- "$@"
	expect_existing "${src_file}"

	local dst_dir
	dst_dir=$( dirname "${dst_file}" ) || die

	rm -f "{dst_file}" || die
	mkdir -p "${dst_dir}" || die
	cp -p "${src_file}" "${dst_file}" || die
}
