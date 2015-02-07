bashmenot_internal_tar_create () {
	local src_dir dst_file
	expect_args src_dir dst_file -- "$@"
	shift 2

	expect_existing "${src_dir}" || return 1

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
		log_error "Unexpected archive format: ${name}"
		return 1
	esac
}


bashmenot_internal_tar_extract () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2

	expect_existing "${src_file}" || return 1

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
		log_error "Unexpected archive format: ${name}"
		return 1
	esac
}


copy_file () {
	local src_file dst_file
	expect_args src_file dst_file -- "$@"

	expect_existing "${src_file}" || return 1

	local dst_dir
	dst_dir=$( dirname "${dst_file}" ) || return 1

	mkdir -p "${dst_dir}" || return 1

	cp "${src_file}" "${dst_file}" 2>&1 | quote || return 1
}


copy_dir_entry_into () {
	local src_dir src_file dst_dir
	expect_args src_dir src_file dst_dir -- "$@"
	shift 3

	expect_existing "${src_dir}/${src_file}" || return 1

	mkdir -p "${dst_dir}" || return 1

	COPYFILE_DISABLE=1 \
		tar -c -f - -C "${src_dir}" "$@" "${src_file}" |
		tar -xp -f - -C "${dst_dir}" 2>&1 | quote || return 1
}


copy_dir_glob_into () {
	local src_dir src_glob dst_dir
	expect_args src_dir src_glob dst_dir -- "$@"
	shift 3

	expect_existing "${src_dir}" || return 1

	# TODO: Use read -rd $'\0'.

	local glob_file
	expand_glob "${src_dir}" "${src_glob}" |
		while read -r glob_file; do
			copy_dir_entry_into "${src_dir}" "${glob_file}" "${dst_dir}" "$@" || return 1
		done || return 1
}


copy_dir_into () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2

	expect_existing "${src_dir}" || return 1

	mkdir -p "${dst_dir}" || return 1

	COPYFILE_DISABLE=1 \
		tar -c -f - -C "${src_dir}" "$@" '.' |
		tar -xp -f - -C "${dst_dir}" 2>&1 | quote || return 1
}


copy_dir_over () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2

	expect_existing "${src_dir}" || return 1

	rm -rf "${dst_dir}" || return 1

	copy_dir_into "${src_dir}" "${dst_dir}" "$@" || return 1
}


create_archive () {
	local src_dir dst_file
	expect_args src_dir dst_file -- "$@"
	shift 2

	expect_existing "${src_dir}" || return 1

	local name stderr
	name=$( basename "${dst_file}" ) || return 1
	stderr=$( get_tmp_file 'tar.stderr' ) || return 1

	log_indent_begin "Creating ${name}..."

	if ! bashmenot_internal_tar_create "${src_dir}" "${dst_file}" "$@" 2>"${stderr}"; then
		log_indent_end 'error'

		quote <"${stderr}"
		return 1
	fi

	local size
	size=$( get_size "${dst_file}" ) || return 1
	log_indent_end "done, ${size}"

	rm -f "${stderr}" || true
}


extract_archive_into () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2

	expect_existing "${src_file}" || return 1

	local name stderr
	name=$( basename "${src_file}" ) || return 1
	stderr=$( get_tmp_file 'tar.stderr' ) || return 1

	log_indent_begin "Extracting ${name}..."

	if ! bashmenot_internal_tar_extract "${src_file}" "${dst_dir}" "$@" 2>"${stderr}"; then
		log_indent_end 'error'

		quote <"${stderr}"
		return 1
	fi

	local size
	size=$( get_size "${dst_dir}" ) || return 1
	log_indent_end "done, ${size}"

	rm -f "${stderr}" || true
}


extract_archive_over () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2

	expect_existing "${src_file}" || return 1

	rm -rf "${dst_dir}" || return 1

	extract_archive_into "${src_file}" "${dst_dir}" || return 1
}


case $( uname -s ) in
'Linux'|'FreeBSD')
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
'Darwin')
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
		log_warning 'Cannot strip'
	}
esac
