format_platform_description () {
	local os
	expect_args os -- "$@"

	case "${os}" in
	'linux-ubuntu-14.04-x86_64')	echo 'Ubuntu 14.04 LTS (64-bit)';;
	'linux-ubuntu-12.04-x86_64')	echo 'Ubuntu 12.04 LTS (64-bit)';;
	'linux-ubuntu-10.04-x86_64')	echo 'Ubuntu 10.04 LTS (64-bit)';;
	'osx-10.9-x86_64')		echo 'OS X 10.9 (64-bit)';;
	'osx-10.10-x86_64')		echo 'OS X 10.10 (64-bit)';;
	*)				echo 'unknown'
	esac
}


detect_arch () {
	local arch
	arch=$( uname -m | tr '[:upper:]' '[:lower:]' ) || die

	case "${arch}" in
	'amd64');&
	'x64');&
	'x86-64');&
	'x86_64')	echo 'x86_64';;
	*)		echo 'unknown'
	esac
}


detect_os () {
	local raw_name
	raw_name=$( uname -s ) || die

	local name raw_dist raw_version
	case "${raw_name}" in
	'Linux')
		name='linux'
		if [[ -f '/etc/os-release' ]]; then
			raw_dist=$( awk -F= '/^ID=/ { print $2 }' <'/etc/os-release' ) || die
			raw_version=$( awk -F= '/^VERSION_ID=/ { print $2 }' <'/etc/os-release' ) || die
		elif [[ -f '/etc/lsb-release' ]]; then
			raw_dist=$( awk -F= '/^DISTRIB_ID=/ { print $2 }' <'/etc/lsb-release' ) || die
			raw_version=$( awk -F= '/^DISTRIB_RELEASE=/ { print $2 }' <'/etc/lsb-release' ) || die
		else
			raw_dist='unknown'
			raw_version=''
		fi
		;;
	'Darwin')
		name='osx'
		raw_dist=''
		raw_version=$( sw_vers -productVersion ) || die
		;;
	*)
		name='unknown'
		raw_dist=''
		raw_version=''
	esac

	local dist version
	dist=$( tr -dc '[:alpha:]' <<<"${raw_dist}" | tr '[:upper:]' '[:lower:]' ) || die
	version=$( tr -dc '[:digit:]\.' <<<"${raw_version}" | sed 's/^\([0-9]*\.[0-9]*\).*$/\1/' ) || die

	echo "${name}${dist:+-${dist}}${version:+-${version}}"
}


detect_platform () {
	local os arch
	os=$( detect_os ) || die
	arch=$( detect_arch ) || die

	echo "${os}-${arch}"
}
