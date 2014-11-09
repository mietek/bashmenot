filter_first () {
	head -n 1 || true
}


filter_last () {
	tail -n 1 || true
}


filter_not_last () {
	sed '$d' || true
}


filter_matching () {
	local pattern
	expect_args pattern -- "$@"

	awk '/'"${pattern//\//\\/}"'/ { print }' || true
}


filter_not_matching () {
	local pattern
	expect_args pattern -- "$@"

	awk '!/'"${pattern//\//\\/}"'/ { print }' || true
}


match_at_most_one () {
	awk 'NR == 1 { line = $0 "\n" } NR == 2 { line = ""; exit 1 } END { printf line }'
}


match_at_least_one () {
	grep '.'
}


match_exactly_one () {
	match_at_most_one | match_at_least_one
}


strip_trailing_newline () {
	awk 'NR > 1 { printf "\n" } { printf "%s", $0 }' || true
}
