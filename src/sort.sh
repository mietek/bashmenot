#!/usr/bin/env bash


case "$( detect_os )" in
'linux-'*)
	function sort_naturally () {
		sort -V "$@"
	}
	;;
*)
	function sort_naturally () {
		gsort -V "$@"
	}
esac


function sort0_naturally () {
	sort_naturally -z
}
