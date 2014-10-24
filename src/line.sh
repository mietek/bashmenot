function filter_last () {
	tail -n 1 || return 0
}


function filter_not_last () {
	sed '$d' || return 0
}


function filter_matching () {
	local pattern
	expect_args pattern -- "$@"

	awk '/'"${pattern//\//\\/}"'/ { print }' || return 0
}


function filter_not_matching () {
	local pattern
	expect_args pattern -- "$@"

	awk '!/'"${pattern//\//\\/}"'/ { print }' || return 0
}


function match_at_most_one () {
	awk 'NR == 1 { line = $0 "\n" } NR == 2 { line = ""; exit 1 } END { printf line }' || return 1
}


function match_at_least_one () {
	grep . || return 1
}


function match_exactly_one () {
	match_at_most_one | match_at_least_one || return 1
}


function strip_trailing_newline () {
	awk 'NR > 1 { printf "\n" } { printf "%s", $0 }' || return 1
}
