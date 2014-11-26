format_platform_description () {
	local platform
	expect_args platform -- "$@"

	case "${platform}" in
	'linux-ubuntu-14.10-x86_64')	echo 'Ubuntu 14.10 (x86_64)';;
	'linux-ubuntu-14.04-x86_64')	echo 'Ubuntu 14.04 LTS (x86_64)';;
	'linux-ubuntu-12.04-x86_64')	echo 'Ubuntu 12.04 LTS (x86_64)';;
	'linux-ubuntu-10.04-x86_64')	echo 'Ubuntu 10.04 LTS (x86_64)';;
	'linux-centos-7-x86_64')	echo 'CentOS 7 (x86_64)';;
	'linux-centos-6-x86_64')	echo 'CentOS 6 (x86_64)';;
	'linux-centos-5-x86_64')	echo 'CentOS 5 (x86_64)';;
	'osx-10.9-x86_64')		echo 'OS X 10.9 (x86_64)';;
	'osx-10.10-x86_64')		echo 'OS X 10.10 (x86_64)';;
	*)				echo 'unknown'
	esac
}


detect_arch () {
	local arch
	arch=''

	local raw_arch
	raw_arch=$( uname -m | tr '[:upper:]' '[:lower:]' ) || true
	case "${raw_arch}" in
	'amd64');&
	'x64');&
	'x86-64');&
	'x86_64')
		arch='x86_64'
		;;
	*)
		true
	esac

	echo "${arch}"
}


detect_linux_label () {
	local label
	label=''

	if [[ -f '/etc/os-release' ]]; then
		label=$( awk -F= '/^ID=/ { print $2 }' <'/etc/os-release' ) || true
	elif [[ -f '/etc/lsb-release' ]]; then
		label=$( awk -F= '/^DISTRIB_ID=/ { print $2 }' <'/etc/lsb-release' ) || true
	elif [[ -f '/etc/centos-release' ]]; then
		label='centos'
	elif [[ -f '/etc/redhat-release' ]]; then
		case $( <'/etc/redhat-release' ) in
		'CentOS'*)
			label='centos';;
		*)
			true
		esac
	fi

	echo "${label}"
}


detect_linux_version () {
	local version
	version=''

	if [[ -f '/etc/os-release' ]]; then
		version=$( awk -F= '/^VERSION_ID=/ { print $2 }' <'/etc/os-release' ) || true
	elif [[ -f '/etc/lsb-release' ]]; then
		version=$( awk -F= '/^DISTRIB_RELEASE=/ { print $2 }' <'/etc/lsb-release' ) || true
	elif [[ -f '/etc/centos-release' ]]; then
		case $( <'/etc/centos-release' ) in
		'CentOS Linux release 7'*)
			version='7';;
		'CentOS release 6'*)
			version='6';;
		*)
			true
		esac
	elif [[ -f '/etc/redhat-release' ]]; then
		case $( <'/etc/centos-release' ) in
		'CentOS release 5'*)
			version='5';;
		*)
			true
		esac
	fi

	echo "${version}"
}


detect_os () {
	local name
	name='unknown'

	local raw_name raw_label raw_version
	raw_name=$( uname -s ) || true
	raw_label=''
	raw_version=''
	case "${raw_name}" in
	'Linux')
		name='linux'
		raw_label=$( detect_linux_label ) || true
		raw_version=$( detect_linux_version ) || true
		;;
	'Darwin')
		name='osx'
		raw_version=$( sw_vers -productVersion ) || true
		;;
	*)
		true
	esac

	local label version
	label=$( tr -dc '[:alpha:]' <<<"${raw_label}" | tr '[:upper:]' '[:lower:]' ) || true
	version=$( tr -dc '[:digit:]\.' <<<"${raw_version}" | sed 's/^\([0-9]*\.[0-9]*\).*$/\1/' ) || true

	echo "${name}${label:+-${label}}${version:+-${version}}"
}


detect_platform () {
	local os arch
	os='unknown'
	os=$( detect_os ) || true
	arch=$( detect_arch ) || true

	echo "${os}${arch:+-${arch}}"
}
