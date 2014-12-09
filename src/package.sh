install_deb_package () {
	local package_file dst_dir
	expect_args package_file dst_dir -- "$@"
	expect_existing "${package_file}"

	local src_dir
	src_dir=$( get_tmp_dir 'deb' )

	dpkg --extract "${package_file}" "${src_dir}" 2>&1 | quote || return 1

	if [[ -d "${src_dir}/usr/include/x86_64-linux-gnu" ]]; then
		copy_dir_into "${src_dir}/usr/include/x86_64-linux-gnu" "${dst_dir}/usr/include" || return 1
		rm -rf "${src_dir}/usr/include/x86_64-linux-gnu" || return 1
	fi
	if [[ -d "${src_dir}/lib" ]]; then
		copy_dir_into "${src_dir}/lib" "${dst_dir}/usr/lib" || return 1
		rm -rf "${src_dir}/lib" || return 1
	fi
	if [[ -d "${src_dir}/lib/x86_64-linux-gnu" ]]; then
		copy_dir_into "${src_dir}/lib/x86_64-linux-gnu" "${dst_dir}/usr/lib" || return 1
		rm -rf "${src_dir}/lib/x86_64-linux-gnu" || return 1
	fi
	if [[ -d "${src_dir}/usr/lib/x86_64-linux-gnu" ]]; then
		copy_dir_into "${src_dir}/usr/lib/x86_64-linux-gnu" "${dst_dir}/usr/lib" || return 1
		rm -rf "${src_dir}/usr/lib/x86_64-linux-gnu" || return 1
	fi

	copy_dir_into "${src_dir}" "${dst_dir}" || return 1
	rm -rf "${src_dir}" || return 1
}


install_rpm_package () {
	local package_file dst_dir
	expect_args package_file dst_dir -- "$@"
	expect_existing "${package_file}"

	local src_dir
	src_dir=$( get_tmp_dir 'rpm' )

	mkdir -p "${src_dir}" || return 1
	(
		cd "${src_dir}" &&
		rpm2cpio "${package_file}" | cpio --extract --make-directories 2>&1 | quote || return 1
	) || return 1

	if [[ -d "${src_dir}/lib" ]]; then
		copy_dir_into "${src_dir}/lib" "${dst_dir}/usr/lib" || return 1
		rm -rf "${src_dir}/lib" || return 1
	fi
	if [[ -d "${src_dir}/lib64" ]]; then
		copy_dir_into "${src_dir}/lib64" "${dst_dir}/usr/lib" || return 1
		rm -rf "${src_dir}/lib64" || return 1
	fi
	if [[ -d "${src_dir}/usr/lib64" ]]; then
		copy_dir_into "${src_dir}/usr/lib64" "${dst_dir}/usr/lib" || return 1
		rm -rf "${src_dir}/usr/lib64" || return 1
	fi

	copy_dir_into "${src_dir}" "${dst_dir}" || return 1
	rm -rf "${src_dir}" || return 1
}


install_debian_packages () {
	local package_names dst_dir
	expect_args package_names dst_dir -- "$@"

	local -a names
	names=( ${package_names} )
	if [[ -z "${names[@]:+_}" ]]; then
		return 0
	fi

	local apt_dir
	apt_dir=$( get_tmp_dir 'apt' ) || return 1

	local -a opts
	opts+=( -o debug::nolocking='true' )
	opts+=( -o dir::cache="${apt_dir}/cache" )
	opts+=( -o dir::state="${apt_dir}/state" )

	mkdir -p "${apt_dir}/state/lists/partial" "${apt_dir}/cache/archives/partial" || return 1
	apt-get "${opts[@]}" update 2>&1 | quote || return 1

	local name
	for name in "${names[@]}"; do
		mkdir -p "${apt_dir}/cache/archives/partial" || return 1
		apt-get "${opts[@]}" install --download-only --reinstall --yes "${name}" 2>&1 | quote || return 1

		local file
		find_tree "${apt_dir}/cache/archives" -type f -name '*.deb' |
			sort_natural |
			while read -r file; do
				install_deb_package "${apt_dir}/cache/archives/${file}" "${dst_dir}" || return 1
			done

		rm -rf "${apt_dir}/cache/archives" || return 1
	done

	rm -rf "${apt_dir}" || return 1
}


install_redhat_packages () {
	local package_names dst_dir
	expect_args package_names dst_dir -- "$@"

	local -a names
	names=( ${package_names} )
	if [[ -z "${names[@]:+_}" ]]; then
		return 0
	fi

	local yum_dir
	yum_dir=$( get_tmp_dir 'yum' ) || return 1

	local -a opts
	opts+=( --assumeyes )
	opts+=( --downloadonly )
	opts+=( --downloaddir="${yum_dir}" )

	# NOTE: In old versions of yum, the --downloadonly option is
	# provided by yum-plugin-downloadonly, which must be installed
	# manually, and which causes yum to always return failure.

	local platform no_status
	platform=$( detect_platform )
	no_status=0
	if [[ "${platform}" == 'linux-centos-6-x86_64' ]]; then
		no_status=1
	fi

	local name
	for name in "${names[@]}"; do
		local status
		status=0

		if ! yum list installed "${name}" >'/dev/null' 2>&1; then
			if ! yum install "${opts[@]}" "${name}" 2>&1 | quote; then
				status=1
			fi
		elif ! yum reinstall "${opts[@]}" "${name}" 2>&1 | quote; then
			status=1
		fi
		if ! (( no_status )) && (( status )); then
			return 1
		fi

		local file
		find_tree "${yum_dir}" -type f -name '*.rpm' |
			sort_natural |
			while read -r file; do
				install_rpm_package "${yum_dir}/${file}" "${dst_dir}" || return 1
			done

		rm -rf "${yum_dir}" || return 1
	done
}


install_platform_packages () {
	local package_specs dst_dir
	expect_args package_specs dst_dir -- "$@"

	local platform
	platform=$( detect_platform )

	local -a specs
	specs=( ${package_specs} )
	if [[ -z "${specs[@]:+_}" ]]; then
		return 0
	fi

	local -a names
	local spec
	for spec in "${specs[@]}"; do
		local pattern name
		pattern="${spec%:*}"
		name="${spec#*:}"
		if [[ "${pattern}" == "${name}" || "${platform}" =~ ${pattern} ]]; then
			names+=( "${name}" )
		fi
	done
	if [[ -z "${names[@]:+_}" ]]; then
		return 0
	fi

	local package_names
	package_names=$( IFS=$'\n' && echo "${names[*]:-}" )

	case "${platform}" in
	'linux-debian-'*|'linux-ubuntu-'*)
		install_debian_packages "${package_names}" "${dst_dir}" || return 1
		;;
	'linux-centos-'*|'linux-fedora-'*)
		install_redhat_packages "${package_names}" "${dst_dir}" || return 1
		;;
	*)
		local description
		description=$( format_platform_description "${platform}" )

		log_error "Cannot install OS packages on ${description}"
		return 1
	esac
}
