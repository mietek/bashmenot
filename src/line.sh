function filter_last () {
	tail -n 1 || true
}


function filter_not_last () {
	sed '$d' || true
}


function filter_matching () {
	local pattern
	expect_args pattern -- "$@"

	awk '/'"${pattern//\//\\/}"'/ { print }' || true
}


function filter_not_matching () {
	local pattern
	expect_args pattern -- "$@"

	awk '!/'"${pattern//\//\\/}"'/ { print }' || true
}


function match_at_most_one () {
	awk 'NR == 1 { line = $0 "\n" } NR == 2 { line = ""; exit 1 } END { printf line }' || false
}


function match_at_least_one () {
	grep . || false
}


function match_exactly_one () {
	match_at_most_one | match_at_least_one || false
}


function strip_trailing_newline () {
	awk 'NR > 1 { printf "\n" } { printf "%s", $0 }' || false
}
