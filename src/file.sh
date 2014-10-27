function get_tmp_file () {
	local base
	expect_args base -- "$@"

	mktemp -u "/tmp/${base}.XXXXXXXXXX" || die
}


function get_tmp_dir () {
	local base
	expect_args base -- "$@"

	mktemp -du "/tmp/${base}.XXXXXXXXXX" || die
}


case "$( detect_os )" in
'linux-'*)
	function get_file_modification_time () {
		local file
		expect_args file -- "$@"

		stat -c "%Y" "${file}" || die
	}
	;;
*)
	function get_file_modification_time () {
		local file
		expect_args file -- "$@"

		stat -f "%m" "${file}" || die
	}
esac


function get_dir_path () {
	local dir
	expect_args dir -- "$@"

	( cd "${dir}" && pwd -P ) || die
}


function get_dir_name () {
	local dir
	expect_args dir -- "$@"

	local path
	path=$( get_dir_path "${dir}" ) || die

	basename "${path}" || die
}


function find_added () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	local new_file
	find "${new_dir}" -type f -print0 2>'/dev/null' |
		sort0_naturally |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"
			if ! [ -f "${old_file}" ]; then
				echo "${path}"
			fi
		done || return 0
}


function find_changed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	local new_file
	find "${new_dir}" -type f -print0 2>'/dev/null' |
		sort0_naturally |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"
			if [ -f "${old_file}" ] && ! cmp -s "${old_file}" "${new_file}"; then
				echo "${path}"
			fi
		done || return 0
}


function find_not_changed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	local new_file
	find "${new_dir}" -type f -print0 2>'/dev/null' |
		sort0_naturally |
		while read -rd $'\0' new_file; do
			local path old_file
			path="${new_file##${new_dir}/}"
			old_file="${old_dir}/${path}"
			if [ -f "${old_file}" ] && cmp -s "${old_file}" "${new_file}"; then
				echo "${path}"
			fi
		done || return 0
}


function find_removed () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	local old_file
	find "${old_dir}" -type f -print0 2>'/dev/null' |
		sort0_naturally |
		while read -rd $'\0' old_file; do
			local path new_file
			path="${old_file##${old_dir}/}"
			new_file="${new_dir}/${path}"
			if ! [ -f "${new_file}" ]; then
				echo "${path}"
			fi
		done || return 0
}


function find_tree () {
	local dir
	expect_args dir -- "$@"
	shift
	[ -d "${dir}" ] || return 0

	( cd "${dir}" && find . "$@" ) || die
}


function do_hash () {
	local input
	input=$( cat ) || die
	[ -n "${input}" ] || return 0

	openssl sha1 <<<"${input}" |
		sed 's/^.* //' || die
}


function hash_tree () {
	local dir
	expect_args dir -- "$@"
	shift
	[ -d "${dir}" ] || return 0

	( cd "${dir}" && find . "$@" -type f -exec openssl sha1 '{}' ';' ) |
		sort_naturally |
		do_hash || die
}


function compare_tree () {
	local old_dir new_dir
	expect_args old_dir new_dir -- "$@"

	(
		find_added "${old_dir}" "${new_dir}" | sed 's/$/ +/'
		find_changed "${old_dir}" "${new_dir}" | sed 's/$/ */'
		find_not_changed "${old_dir}" "${new_dir}" | sed 's/$/ =/'
		find_removed "${old_dir}" "${new_dir}" | sed 's/$/ -/'
	) |
		sort_naturally |
		awk '{ print $2 " " $1 }' || return 0
}


function size_tree () {
	local dir
	expect_args dir -- "$@"

	du -sh "${dir}" | awk '{ print $1 }' || die
}


case "$( detect_os )" in
'linux-'*)
	function strip_tree () {
		local dir
		expect_args dir -- "$@"

		local file
		find "${dir}" -type f -print0 2>'/dev/null' |
			sort0_naturally |
			while read -rd $'\0' file; do
				strip --strip-unneeded "${file}" 2>'/dev/null' || true
			done || return 0
	}
	;;
'os-x'*)
	function strip_tree () {
		local dir
		expect_args dir -- "$@"

		local file
		find "${dir}" -type f -print0 2>'/dev/null' |
			sort0_naturally |
			while read -rd $'\0' file; do
				strip -u -r "${file}"
			done || return 0
	}
	;;
*)
	function strip_tree () {
		log_warning 'Stripping is unsupported on this OS'
		return 0
	}
esac
