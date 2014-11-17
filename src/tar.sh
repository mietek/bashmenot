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
	'gz')
		if which 'pigz' &>'/dev/null'; then
			COPYFILE_DISABLE=1 \
				tar -c -C "${src_dir}" "$@" '.' |
				pigz -7 >"${dst_file}" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -c -z -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
		fi
		;;
	'bz2')
		if which 'pbzip2' &>'/dev/null'; then
			COPYFILE_DISABLE=1 \
				tar -c -C "${src_dir}" "$@" '.' |
				pbzip2 -7 >"${dst_file}" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -c -j -f "${dst_file}" -C "${src_dir}" "$@" '.' || return 1
		fi
		;;
	'xz')
		if which 'pxz' &>'/dev/null'; then
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
	'gz')
		if which 'pigz' &>'/dev/null'; then
			COPYFILE_DISABLE=1 \
				pigz -d <"${src_file}" |
				tar -x -C "${dst_dir}" "$@" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -x -z -f "${src_file}" -C "${dst_dir}" "$@" || return 1
		fi
		;;
	'bz2')
		if which 'pbzip2' &>'/dev/null'; then
			COPYFILE_DISABLE=1 \
				pbzip2 -d <"${src_file}" |
				tar -x -C "${dst_dir}" "$@" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -x -j -f "${src_file}" -C "${dst_dir}" "$@" || return 1
		fi
		;;
	'xz')
		if which 'pxz' &>'/dev/null'; then
			COPYFILE_DISABLE=1 \
				pxz -d <"${src_file}" |
				tar -x -C "${dst_dir}" "$@" || return 1
		else
			COPYFILE_DISABLE=1 \
				tar -x -J -f "${src_file}" -C "${dst_dir}" "$@" || return 1
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

	cp -p "${src_file}" "${dst_file}" |& quote
}


copy_dir_into () {
	local src_dir dst_dir
	expect_args src_dir dst_dir -- "$@"
	shift 2
	expect_existing "${src_dir}"

	mkdir -p "${dst_dir}" || return 1

	COPYFILE_DISABLE=1 \
		tar -c -f - -C "${src_dir}" "$@" '.' |
		tar -x -f - -C "${dst_dir}" |& quote
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
	stderr=$( get_tmp_file 'tar-create-stderr' ) || return 1

	log_indent_begin "Creating ${name}..."

	if ! bashnot_internal_tar_create "${src_dir}" "${dst_file}" "$@" 2>"${stderr}"; then
		log_end 'error'
		quote <"${stderr}"
		return 1
	fi

	local size
	size=$( get_size "${dst_file}" ) || return 1
	log_end "done, ${size}"
}


extract_archive_into () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	local name stderr
	name=$( basename "${src_file}" ) || return 1
	stderr=$( get_tmp_file 'tar-extract-stderr' ) || return 1

	log_indent_begin "Extracting ${name}..."

	if ! bashnot_internal_tar_extract "${src_file}" "${dst_dir}" "$@" 2>"${stderr}"; then
		log_end 'error'
		quote <"${stderr}"
		return 1
	fi

	local size
	size=$( get_size "${dst_dir}" ) || return 1
	log_end "done, ${size}"
}


extract_archive_over () {
	local src_file dst_dir
	expect_args src_file dst_dir -- "$@"
	shift 2
	expect_existing "${src_file}"

	rm -rf "${dst_dir}" || return 1

	extract_archive_into "${src_file}" "${dst_dir}"
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
				strip --strip-unneeded "${file}" 2>'/dev/null' | quote
			done || true
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
				strip -u -r "${file}" 2>'/dev/null' | quote
			done || true
	}
	;;
*)
	true
esac
