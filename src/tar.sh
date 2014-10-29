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
	local src_dir file
	expect_args src_dir file -- "$@"
	shift 2

	if ! [ -d "${src_dir}" ]; then
		return 1
	fi

	local name flag dst_dir
	name=$( basename "${file}" ) || die
	flag=$( map_extension_to_tar_flag "${name}" ) || die
	dst_dir=$( dirname "${file}" ) || die

	log_indent_begin "Creating ${name}..."

	rm -f "${file}" || die
	mkdir -p "${dst_dir}" || die

	if ! COPYFILE_DISABLE=1 tar -c "${flag}" -f "${file}" -C "${src_dir}" "$@" '.' 2>'/dev/null'; then
		rm -f "${file}" || die
		log_end 'error'
		return 1
	fi

	local size
	size=$( size_tree "${file}" ) || die
	log_end "done, ${size}"
}


function tar_extract () {
	local file dir
	expect_args file dir -- "$@"
	shift 2

	if ! [ -f "${file}" ]; then
		return 1
	fi

	local name flag
	name=$( basename "${file}" ) || die
	flag=$( map_extension_to_tar_flag "${name}" ) || die

	log_indent_begin "Extracting ${name}..."

	mkdir -p "${dir}" || die

	if ! COPYFILE_DISABLE=1 tar -x "${flag}" -f "${file}" -C "${dir}" "$@" 2>'/dev/null'; then
		log_end 'error'
		return 1
	fi

	local size
	size=$( size_tree "${dir}" ) || die
	log_end "done, ${size}"
}


function tar_copy () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2

	if ! [ -d "${src_dir}" ]; then
		return 1
	fi

	mkdir -p "${dst_dir}" || die

	if ! COPYFILE_DISABLE=1 tar -c -f - -C "${src_dir}" "$@" '.' 2>'/dev/null' |
		COPYFILE_DISABLE=1 tar -x -f - -C "${dst_dir}" 2>'/dev/null'
	then
		return 1
	fi
}
