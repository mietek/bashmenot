function echo_os_description () {
	local os
	expect_args os -- "$@"

	case "${os}" in
	'linux-ubuntu-14-04-x86_64')
		echo 'Ubuntu 14.04 LTS (64-bit)';;
	'linux-ubuntu-12-04-x86_64')
		echo 'Ubuntu 12.04 LTS (64-bit)';;
	'linux-ubuntu-10-04-x86_64')
		echo 'Ubuntu 10.04 LTS (64-bit)';;
	*)
		die "Unexpected OS: ${os}"
	esac
}


function detect_arch () {
	local arch
	arch=$( uname -m | tr '[:upper:]' '[:lower:]' ) || die

	case "${arch}" in
	'amd64');&
	'x64');&
	'x86-64');&
	'x86_64')
		echo 'x86_64';;
	*)
		die "Unexpected architecture: ${arch}"
	esac
}


function detect_os () {
	local os arch
	os=$( uname -s ) || die
	arch=$( detect_arch ) || die

	case "${os}" in
	'Linux')
		if ! [ -f '/etc/lsb-release' ]; then
			echo "linux-unknown-${arch}"
		else
			local distrib release
			distrib=$(
				awk -F= '/DISTRIB_ID/ { print $2 }' <'/etc/lsb-release' |
				tr '[:upper:]' '[:lower:]'
			) || die
			release=$(
				awk -F= '/DISTRIB_RELEASE/ { print $2 }' <'/etc/lsb-release' |
				tr '.' '-'
			) || die
			echo "linux-${distrib}-${release}-${arch}"
		fi
		;;
	'Darwin')
		echo "darwin-${arch}";;
	*)
		echo "unknown-${arch}"
	esac
}
