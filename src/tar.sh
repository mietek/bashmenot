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


function tar_archive () {
	local src_dir file
	expect_args src_dir file -- "$@"
	shift 2
	[ -d "${src_dir}" ] || return 1

	local name flag dst_dir
	name=$( basename "${file}" ) || die
	flag=$( map_extension_to_tar_flag "${name}" ) || die
	dst_dir=$( dirname "${file}" ) || die

	log_indent_begin "Archiving ${name}..."

	rm -f "${file}" || die
	mkdir -p "${dst_dir}" || die

	if ! tar -c "${flag}" -f "${file}" -C "${src_dir}" "$@" '.' 2>'/dev/null'; then
		rm -f "${file}" || die
		log_end 'error'
		return 1
	fi

	local size
	size=$( measure_recursively "${file}" ) || die
	log_end "done (${size})"
}


function tar_extract () {
	local file dir
	expect_args file dir -- "$@"
	shift 2
	[ -f "${file}" ] || return 1

	local name flag
	name=$( basename "${file}" ) || die
	flag=$( map_extension_to_tar_flag "${name}" ) || die

	log_indent_begin "Extracting ${name}..."

	rm -rf "${dir}" || die
	mkdir -p "${dir}" || die

	if ! tar -x "${flag}" -f "${file}" -C "${dir}" "$@" 2>'/dev/null'; then
		rm -rf "${dir}" || die
		log_end 'error'
		return 1
	fi

	log_end 'done'
}


function tar_copy () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	[ -d "${src_dir}" ] || return 1

	rm -rf "${dst_dir}" || die
	mkdir -p "${dst_dir}" || die

	if ! tar -c -f - -C "${src_dir}" "$@" '.' 2>'/dev/null' |
		tar -x -f - -C "${dst_dir}" 2>'/dev/null'
	then
		return 1
	fi
}
