format_platform_description () {
	case "$1" in
	'freebsd-10.0-x86_64')		echo 'FreeBSD 10.0 (x86_64)';;
	'freebsd-10.1-x86_64')		echo 'FreeBSD 10.1 (x86_64)';;
	'linux-amzn-2014.09-x86_64')	echo 'Amazon Linux 2014.09 (x86_64)';;
	'linux-arch-x86_64')		echo 'Arch Linux (x86_64)';;
	'linux-centos-6-i386')		echo 'CentOS 6 (i386)';;
	'linux-centos-6-x86_64')	echo 'CentOS 6 (x86_64)';;
	'linux-centos-7-i386')		echo 'CentOS 7 (i386)';;
	'linux-centos-7-x86_64')	echo 'CentOS 7 (x86_64)';;
	'linux-debian-6-i386')		echo 'Debian 6 (i386)';;
	'linux-debian-6-x86_64')	echo 'Debian 6 (x86_64)';;
	'linux-debian-7-i386')		echo 'Debian 7 (i386)';;
	'linux-debian-7-x86_64')	echo 'Debian 7 (x86_64)';;
	'linux-debian-8-i386')		echo 'Debian 8 (i386)';;
	'linux-debian-8-x86_64')	echo 'Debian 8 (x86_64)';;
	'linux-exherbo-x86_64')		echo 'Exherbo Linux (x86_64)';;
	'linux-fedora-19-i386')		echo 'Fedora 19 (i386)';;
	'linux-fedora-19-x86_64')	echo 'Fedora 19 (x86_64)';;
	'linux-fedora-20-i386')		echo 'Fedora 20 (i386)';;
	'linux-fedora-20-x86_64')	echo 'Fedora 20 (x86_64)';;
	'linux-fedora-21-x86_64')	echo 'Fedora 21 (x86_64)';;
	'linux-gentoo-x86_64')		echo 'Gentoo Linux (x86_64)';;
	'linux-opensuse-13.2-x86_64')	echo 'openSUSE 13.2 (x86_64)';;
	'linux-rhel-6-i386')		echo 'Red Hat Enterprise Linux 6 (i386)';;
	'linux-rhel-6-x86_64')		echo 'Red Hat Enterprise Linux 6 (x86_64)';;
	'linux-rhel-7-x86_64')		echo 'Red Hat Enterprise Linux 7 (x86_64)';;
	'linux-slackware-14.1-x86_64')	echo 'Slackware 14.1 (x86_64)';;
	'linux-sles-11-i386')		echo 'SUSE Linux Enterprise Server 11 (i386)';;
	'linux-sles-11-x86_64')		echo 'SUSE Linux Enterprise Server 11 (x86_64)';;
	'linux-sles-12-x86_64')		echo 'SUSE Linux Enterprise Server 12 (x86_64)';;
	'linux-ubuntu-10.04-i386')	echo 'Ubuntu 10.04 LTS (i386)';;
	'linux-ubuntu-10.04-x86_64')	echo 'Ubuntu 10.04 LTS (x86_64)';;
	'linux-ubuntu-12.04-i386')	echo 'Ubuntu 12.04 LTS (i386)';;
	'linux-ubuntu-12.04-x86_64')	echo 'Ubuntu 12.04 LTS (x86_64)';;
	'linux-ubuntu-14.04-i386')	echo 'Ubuntu 14.04 LTS (i386)';;
	'linux-ubuntu-14.04-x86_64')	echo 'Ubuntu 14.04 LTS (x86_64)';;
	'linux-ubuntu-14.10-i386')	echo 'Ubuntu 14.10 (i386)';;
	'linux-ubuntu-14.10-x86_64')	echo 'Ubuntu 14.10 (x86_64)';;
	'linux-ubuntu-15.04-i386')	echo 'Ubuntu 15.04 (i386)';;
	'linux-ubuntu-15.04-x86_64')	echo 'Ubuntu 15.04 (x86_64)';;
	'osx-10.6-x86_64')		echo 'OS X 10.6 (x86_64)';;
	'osx-10.7-x86_64')		echo 'OS X 10.7 (x86_64)';;
	'osx-10.8-x86_64')		echo 'OS X 10.8 (x86_64)';;
	'osx-10.9-x86_64')		echo 'OS X 10.9 (x86_64)';;
	'osx-10.10-x86_64')		echo 'OS X 10.10 (x86_64)';;
	*)				echo 'unknown'
	esac
}


is_debian_like () {
	case "$1" in
	'linux-debian-'*)	return 0;;
	'linux-ubuntu-'*)	return 0;;
	*)			return 1
	esac
}


is_redhat_like () {
	case "$1" in
	'linux-amzn-'*)		return 0;;
	'linux-centos-'*)	return 0;;
	'linux-fedora-'*)	return 0;;
	'linux-rhel-'*)		return 0;;
	*)			return 1
	esac
}


detect_os () {
	local raw_os
	raw_os=$( uname -s ) || true

	case "${raw_os}" in
	'FreeBSD')	echo 'freebsd';;
	'Linux')	echo 'linux';;
	'Darwin')	echo 'osx';;
	*)		echo 'unknown'
	esac
}


detect_arch () {
	local raw_arch
	raw_arch=$( uname -m | tr '[:upper:]' '[:lower:]' ) || true

	case "${raw_arch}" in
	'amd64')	echo 'x86_64';;
	'i686')		echo 'i386';;
	'x64')		echo 'x86_64';;
	'x86-64')	echo 'x86_64';;
	'x86_64')	echo 'x86_64';;
	*)		echo 'unknown'
	esac
}


bashmenot_internal_detect_linux_label () {
	local label raw_label
	label=''

	if [[ -f '/etc/os-release' ]]; then
		label=$( awk -F= '/^ID=/ { print $2 }' <'/etc/os-release' ) || true
	fi
	if [[ -z "${label}" && -f '/etc/lsb-release' ]]; then
		label=$( awk -F= '/^DISTRIB_ID=/ { print $2 }' <'/etc/lsb-release' ) || true
	fi
	if [[ -z "${label}" && -f '/etc/centos-release' ]]; then
		label='centos'
	fi
	if [[ -z "${label}" && -f '/etc/debian_version' ]]; then
		label='debian'
	fi
	if [[ -z "${label}" && -f '/etc/redhat-release' ]]; then
		raw_label=$( <'/etc/redhat-release' ) || true
		case "${raw_label}" in
		'CentOS'*)
			label='centos';;
		'Red Hat Enterprise Linux Server'*)
			label='rhel';;
		*)
			true
		esac
	fi
	if [[ -z "${label}" && -f '/etc/SuSE-release' ]]; then
		raw_label=$( <'/etc/SuSE-release' ) || true
		case "${raw_label}" in
		'SUSE Linux Enterprise Server'*)
			label='sles';;
		*)
			true
		esac
	fi

	echo "${label}"
}


bashmenot_internal_detect_linux_version () {
	local version raw_version
	version=''

	if [[ -f '/etc/os-release' ]]; then
		version=$( awk -F= '/^VERSION_ID=/ { print $2 }' <'/etc/os-release' ) || true
	fi
	if [[ -z "${version}" && -f '/etc/lsb-release' ]]; then
		version=$( awk -F= '/^DISTRIB_RELEASE=/ { print $2 }' <'/etc/lsb-release' ) || true
	fi
	if [[ -z "${version}" && -f '/etc/centos-release' ]]; then
		raw_version=$( <'/etc/centos-release' ) || true
		case "${raw_version}" in
		'CentOS release 6'*)
			version='6';;
		'CentOS Linux release 7'*)
			version='7';;
		*)
			true
		esac
	fi
	if [[ -z "${version}" && -f '/etc/debian_version' ]]; then
		version=$( sed 's/^\([0-9]*\).*$/\1/' <'/etc/debian_version' ) || true
	fi
	if [[ -z "${version}" && -f '/etc/redhat-release' ]]; then
		raw_version=$( <'/etc/redhat-release' ) || true
		case "${raw_version}" in
		'Red Hat Enterprise Linux Server release 5'*)
			version='5';;
		'Red Hat Enterprise Linux Server release 6'*)
			version='6';;
		*)
			true
		esac
	fi
	if [[ -z "${version}" && -f '/etc/SuSE-release' ]]; then
		raw_version=$( <'/etc/SuSE-release' ) || true
		case "${raw_version}" in
		'SUSE Linux Enterprise Server 11'*)
			version='11';;
		*)
			true
		esac
	fi

	echo "${version}"
}


detect_platform () {
	local os arch
	os=$( detect_os )
	arch=$( detect_arch )

	local raw_label raw_version
	raw_label=''
	raw_version=''
	case "${os}" in
	'freebsd')
		raw_version=$( uname -r | awk -F- '{ print $1 }' ) || true
		;;
	'linux')
		raw_label=$( bashmenot_internal_detect_linux_label ) || true
		raw_version=$( bashmenot_internal_detect_linux_version ) || true
		;;
	'osx')
		raw_version=$( sw_vers -productVersion ) || true
		;;
	*)
		true
	esac

	local label version
	label=$( tr -dc '[:alpha:]' <<<"${raw_label}" | tr '[:upper:]' '[:lower:]' ) || true
	version=$( tr -dc '[:digit:]\.' <<<"${raw_version}" | sed 's/^\([0-9]*\.[0-9]*\).*$/\1/' ) || true
	if [[ "${label}" == 'rhel' ]]; then
		version="${version%%.*}"
	fi

	echo "${os}${label:+-${label}}${version:+-${version}}${arch:+-${arch}}"
}
