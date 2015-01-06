filter_first () {
	head -n 1 || return 0
}


filter_not_first () {
	sed '1d' || return 0
}


filter_last () {
	tail -n 1 || return 0
}


filter_not_last () {
	sed '$d' || return 0
}


filter_matching () {
	local pattern
	expect_args pattern -- "$@"

	awk '/'"${pattern//\//\\/}"'/ { print }' || return 0
}


filter_not_matching () {
	local pattern
	expect_args pattern -- "$@"

	awk '!/'"${pattern//\//\\/}"'/ { print }' || return 0
}


match_at_most_one () {
	awk '	NR == 1 { line = $0 "\n" }
		NR == 2 { line = ""; exit 1 }
		END { printf line }' || return 1
}


match_at_least_one () {
	grep '.' || return 1
}


match_exactly_one () {
	match_at_most_one | match_at_least_one || return 1
}


strip_trailing_newline () {
	awk 'NR > 1 { printf "\n" } { printf "%s", $0 }' || return 0
}
