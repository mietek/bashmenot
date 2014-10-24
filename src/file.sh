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


function compare_recursively () {
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


function find_spaceless_recursively () {
	local dir
	expect_args dir -- "$@"
	shift

	local files
	if ! files=$(
		find "${dir}" "$@" -type f -and \( -path '* *' -prune -or -print \) 2>'/dev/null'
	) || [ -z "${files}" ]; then
		return 0
	fi

	sed "s:^${dir}/::" <<<"${files}" || return 0
}


function do_hash () {
	local input
	input=$( cat ) || die
	if [ -z "${input}" ]; then
		return 0
	fi

	openssl sha1 <<<"${input}" |
		sed 's/^.* //' || die
}


function hash_spaceless_recursively () {
	local dir
	expect_args dir -- "$@"
	shift

	local files
	files=$( find_spaceless_recursively "${dir}" "$@" | sort_naturally ) || die
	if [ -z "${files}" ]; then
		return 0
	fi

	(
		do_hash <<<"${files}" || die

		local file
		for file in ${files}; do
			do_hash <"${dir}/${file}" || die
		done
	) | do_hash || die
}


function measure_recursively () {
	local dir
	expect_args dir -- "$@"

	du -sh "${dir}" | awk '{ print $1 }' || die
}


function copy_entire_contents () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	expect_existing "${src_dir}"

	mkdir -p "${dst_dir}" || die
	cp -Rp "${src_dir}/." "${dst_dir}" || die
}


function copy_dotless_contents () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	expect_existing "${src_dir}"

	mkdir -p "${dst_dir}" || die
	cp -Rp "${src_dir}/"* "${dst_dir}" || die
}


function strip0 () {
	local file
	while read -rd $'\0' file; do
		strip "$@" "${file}" || die
	done || die
}
