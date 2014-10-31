function map_extension_to_tar_flag () {
	local name
	expect_args name -- "$@"

	local format
	format="${name##*.}"

	case "${format}" in
	'gz')	echo '-z';;
	'bz2')	echo '-j';;
	'xz')	echo '-J';;
	*)	die "Unexpected archive format: ${name}"
	esac
}


function tar_create () {
	local src_dir dst_file
	expect_args src_dir dst_file -- "$@"
	shift 2
	expect_existing "${src_dir}"

	local name flag dst_dir
	name=$( basename "${dst_file}" ) || die
	flag=$( map_extension_to_tar_flag "${name}" ) || die
	dst_dir=$( dirname "${dst_file}" ) || die

	mkdir -p "${dst_dir}" || die
	COPYFILE_DISABLE=1 tar -c "${flag}" -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
}


function tar_extract () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	local name flag
	name=$( basename "${src_file}" ) || die
	flag=$( map_extension_to_tar_flag "${name}" ) || die

	mkdir -p "${dst_dir}" || die
	COPYFILE_DISABLE=1 tar -x "${flag}" -f "${src_file}" -C "${dst_dir}" "$@" || return 1
}


function tar_copy () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	expect_existing "${src_dir}"

	mkdir -p "${dst_dir}" || die
	COPYFILE_DISABLE=1 tar -c -f - -C "${src_dir}" "$@" '.' |
		COPYFILE_DISABLE=1 tar -x -f - -C "${dst_dir}" || return 1
}


function create_archive () {
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
	size=$( size_tree "${dst_file}" ) || die
	log_end "done, ${size}"
}


function extract_archive_into () {
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
	size=$( size_tree "${dst_dir}" ) || die
	log_end "done, ${size}"
}


function extract_archive_over () {
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
	size=$( size_tree "${dst_dir}" ) || die
	log_end "done, ${size}"
}


function copy_dir_into () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	expect_existing "${src_dir}"

	tar_copy "${src_dir}" "${dst_dir}" "$@" |& quote || return 1
}


function copy_dir_over () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	expect_existing "${src_dir}"

	rm -rf "${dst_dir}" || die
	tar_copy "${src_dir}" "${dst_dir}" "$@" |& quote || return 1
}
