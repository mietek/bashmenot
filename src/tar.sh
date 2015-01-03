bashnot_internal_tar_create () {
	local src_dir dst_file
	expect_args src_dir dst_file -- "$@"
	shift 2
	expect_existing "${src_dir}"

	local name format dst_dir
	name=$( basename "${dst_file}" ) || return 1
	format="${name##*.}"
	dst_dir=$( dirname "${dst_file}" ) || return 1

	mkdir -p "${dst_dir}" || return 1

	case "${format}" in
	'tar')
		COPYFILE_DISABLE=1 \
			tar -c -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
		;;
	'gz')
		if which 'pigz' >'/dev/null' 2>&1; then
			COPYFILE_DISABLE=1 \
				tar -c -C "${src_dir}" "$@" '.' |
				pigz -7 >"${dst_file}" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -c -z -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
		fi
		;;
	'bz2')
		if which 'pbzip2' >'/dev/null' 2>&1; then
			COPYFILE_DISABLE=1 \
				tar -c -C "${src_dir}" "$@" '.' |
				pbzip2 -7 >"${dst_file}" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -c -j -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
		fi
		;;
	'xz')
		if which 'pxz' >'/dev/null' 2>&1; then
			COPYFILE_DISABLE=1 \
				tar -c -C "${src_dir}" "$@" '.' |
				pxz -7 >"${dst_file}" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -c -J -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
		fi
		;;
	*)
		die "Unexpected archive format: ${name}"
	esac
}


bashnot_internal_tar_extract () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	local name format
	name=$( basename "${src_file}" ) || return 1
	format="${name##*.}"

	mkdir -p "${dst_dir}" || return 1

	case "${format}" in
	'tar')
		COPYFILE_DISABLE=1 \
			tar -xp -f "${src_file}" -C "${dst_dir}" "$@" || return 1
		;;
	'gz')
		if which 'pigz' >'/dev/null' 2>&1; then
			COPYFILE_DISABLE=1 \
				pigz -d <"${src_file}" |
				tar -xp -C "${dst_dir}" "$@" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -xp -z -f "${src_file}" -C "${dst_dir}" "$@" || return 1
		fi
		;;
	'bz2')
		if which 'pbzip2' >'/dev/null' 2>&1; then
			COPYFILE_DISABLE=1 \
				pbzip2 -d <"${src_file}" |
				tar -xp -C "${dst_dir}" "$@" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -xp -j -f "${src_file}" -C "${dst_dir}" "$@" || return 1
		fi
		;;
	'xz')
		if which 'pxz' >'/dev/null' 2>&1; then
			COPYFILE_DISABLE=1 \
				pxz -d <"${src_file}" |
				tar -xp -C "${dst_dir}" "$@" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -xp -J -f "${src_file}" -C "${dst_dir}" "$@" || return 1
		fi
		;;
	*)
		die "Unexpected archive format: ${name}"
	esac
}


copy_file () {
	local src_file dst_file
	expect_args src_file dst_file -- "$@"
	expect_existing "${src_file}"

	local dst_dir
	dst_dir=$( dirname "${dst_file}" ) || return 1

	mkdir -p "${dst_dir}" || return 1

	cp -p "${src_file}" "${dst_file}" 2>&1 | quote
}


copy_file_into () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	local src_dir src_name
	src_dir=$( dirname "${src_file}" ) || return 1
	src_name=$( basename "${src_file}" ) || return 1

	mkdir -p "${dst_dir}" || return 1

	COPYFILE_DISABLE=1 \
		tar -c -f - -C "${src_dir}" "$@" "${src_name}" |
		tar -xp -f - -C "${dst_dir}" 2>&1 | quote
}


copy_dir_into () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	expect_existing "${src_dir}"

	mkdir -p "${dst_dir}" || return 1

	COPYFILE_DISABLE=1 \
		tar -c -f - -C "${src_dir}" "$@" '.' |
		tar -xp -f - -C "${dst_dir}" 2>&1 | quote
}


copy_dir_over () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	expect_existing "${src_dir}"

	rm -rf "${dst_dir}" || return 1

	copy_dir_into "${src_dir}" "${dst_dir}" "$@"
}


create_archive () {
	local src_dir dst_file
	expect_args src_dir dst_file -- "$@"
	shift 2
	expect_existing "${src_dir}"

	local name stderr
	name=$( basename "${dst_file}" ) || return 1
	stderr=$( get_tmp_file 'tar' ) || return 1

	log_indent_begin "Creating ${name}..."

	if ! bashnot_internal_tar_create "${src_dir}" "${dst_file}" "$@" 2>"${stderr}"; then
		log_indent_end 'error'
		quote <"${stderr}"
		rm -f "${stderr}" || return 1
		return 1
	fi

	local size
	size=$( get_size "${dst_file}" ) || return 1
	log_indent_end "done, ${size}"
	rm -f "${stderr}" || return 1
}


extract_archive_into () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	local name stderr
	name=$( basename "${src_file}" ) || return 1
	stderr=$( get_tmp_file 'tar' ) || return 1

	log_indent_begin "Extracting ${name}..."

	if ! bashnot_internal_tar_extract "${src_file}" "${dst_dir}" "$@" 2>"${stderr}"; then
		log_indent_end 'error'
		quote <"${stderr}"
		rm -f "${stderr}" || return 1
		return 1
	fi

	local size
	size=$( get_size "${dst_dir}" ) || return 1
	log_indent_end "done, ${size}"
	rm -f "${stderr}" || return 1
}


extract_archive_over () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	rm -rf "${dst_dir}" || return 1

	extract_archive_into "${src_file}" "${dst_dir}"
}


case $( uname -s ) in
'Linux')
	strip_tree () {
		local dir
		expect_args dir -- "$@"

		local file
		find "${dir}" "$@" -type f -print0 2>'/dev/null' |
			sort0_natural |
			while read -rd $'\0' file; do
				strip --strip-unneeded "${file}" 2>'/dev/null' | quote
			done || true
	}
	;;
'Darwin')
	strip_tree () {
		local dir
		expect_args dir -- "$@"

		local file
		find "${dir}" "$@" -type f -print0 2>'/dev/null' |
			sort0_natural |
			while read -rd $'\0' file; do
				strip -u -r "${file}" 2>'/dev/null' | quote
			done || true
	}
	;;
*)
	true
esac
