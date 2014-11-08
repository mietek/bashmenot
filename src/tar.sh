tar_create () {
	local src_dir dst_file
	expect_args src_dir dst_file -- "$@"
	shift 2
	expect_existing "${src_dir}"

	local name format dst_dir
	name=$( basename "${dst_file}" ) || die
	format="${name##*.}"
	dst_dir=$( dirname "${dst_file}" ) || die

	mkdir -p "${dst_dir}" || die

	case "${format}" in
	'gz')	if which 'pigz' &>'/dev/null'; then
			COPYFILE_DISABLE=1 tar -c -C "${src_dir}" "$@" '.' | pigz -7 >"${dst_file}" || return 1
		else
			COPYFILE_DISABLE=1 tar -c -z -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
		fi
		;;
	'bz2')	if which 'pbzip2' &>'/dev/null'; then
			COPYFILE_DISABLE=1 tar -c -C "${src_dir}" "$@" '.' | pbzip2 -7 >"${dst_file}" || return 1
		else
			COPYFILE_DISABLE=1 tar -c -j -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
		fi
		;;
	'xz')	if which 'pxz' &>'/dev/null'; then
			COPYFILE_DISABLE=1 tar -c -C "${src_dir}" "$@" '.' | pxz -7 >"${dst_file}" || return 1
		else
			COPYFILE_DISABLE=1 tar -c -J -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
		fi
		;;
	*)
		die "Unexpected archive format: ${name}"
	esac
}


tar_extract () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	local name format
	name=$( basename "${src_file}" ) || die
	format="${name##*.}"

	mkdir -p "${dst_dir}" || die

	case "${format}" in
	'gz')	if which 'pigz' &>'/dev/null'; then
			COPYFILE_DISABLE=1 pigz -d <"${src_file}" | tar -x -C "${dst_dir}" "$@" || return 1
		else
			COPYFILE_DISABLE=1 tar -x -z -f "${src_file}" -C "${dst_dir}" "$@" || return 1
		fi
		;;
	'bz2')	if which 'pbzip2' &>'/dev/null'; then
			COPYFILE_DISABLE=1 pbzip2 -d <"${src_file}" | tar -x -C "${dst_dir}" "$@" || return 1
		else
			COPYFILE_DISABLE=1 tar -x -j -f "${src_file}" -C "${dst_dir}" "$@" || return 1
		fi
		;;
	'xz')	if which 'pxz' &>'/dev/null'; then
			COPYFILE_DISABLE=1 pxz -d <"${src_file}" | tar -x -C "${dst_dir}" "$@" || return 1
		else
			COPYFILE_DISABLE=1 tar -x -J -f "${src_file}" -C "${dst_dir}" "$@" || return 1
		fi
		;;
	*)
		die "Unexpected archive format: ${name}"
	esac
}


tar_copy () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	expect_existing "${src_dir}"

	mkdir -p "${dst_dir}" || die
	COPYFILE_DISABLE=1 tar -c -f - -C "${src_dir}" "$@" '.' |
		COPYFILE_DISABLE=1 tar -x -f - -C "${dst_dir}" || return 1
}


create_archive () {
	local src_dir dst_file
	expect_args src_dir dst_file -- "$@"
	shift 2
	expect_existing "${src_dir}"

	local name stderr
	name=$( basename "${dst_file}" ) || die
	stderr=$( get_tmp_file 'tar-create-stderr' ) || die

	log_indent_begin "Creating ${name}..."

	rm -f "${dst_file}" || die
	if ! tar_create "${src_dir}" "${dst_file}" "$@" 2>"${stderr}"; then
		log_end 'error'
		quote <"${stderr}" || die
		rm -f "${dst_file}" || die
		return 1
	fi

	local size
	size=$( get_size "${dst_file}" ) || die
	log_end "done, ${size}"
}


extract_archive_into () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	local name flag stderr
	name=$( basename "${src_file}" ) || die
	stderr=$( get_tmp_file 'tar-extract-stderr' ) || die

	log_indent_begin "Extracting ${name}..."

	if ! tar_extract "${src_file}" "${dst_dir}" "$@" 2>"${stderr}"; then
		log_end 'error'
		quote <"${stderr}" || die
		return 1
	fi

	local size
	size=$( get_size "${dst_dir}" ) || die
	log_end "done, ${size}"
}


extract_archive_over () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	local name flag stderr
	name=$( basename "${src_file}" ) || die
	stderr=$( get_tmp_file 'tar-extract-stderr' ) || die

	log_indent_begin "Extracting ${name}..."

	rm -rf "${dst_dir}" || die
	if ! tar_extract "${src_file}" "${dst_dir}" "$@" 2>"${stderr}"; then
		log_end 'error'
		quote <"${stderr}" || die
		return 1
	fi

	local size
	size=$( get_size "${dst_dir}" ) || die
	log_end "done, ${size}"
}


copy_dir_into () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	expect_existing "${src_dir}"

	tar_copy "${src_dir}" "${dst_dir}" "$@" |& quote || return 1
}


copy_dir_over () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	expect_existing "${src_dir}"

	rm -rf "${dst_dir}" || die
	tar_copy "${src_dir}" "${dst_dir}" "$@" |& quote || return 1
}
