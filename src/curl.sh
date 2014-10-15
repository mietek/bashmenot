function echo_http_code_description () {
	local code
	expect_args code -- "$@"

	case "${code}" in
	'200')	echo 'done';;
	'201')	echo '201 Created';;
	'202')	echo '202 Accepted';;
	'203')	echo '203 Non-authoritative information';;
	'204')	echo '204 No content';;
	'205')	echo '205 Reset content';;
	'206')	echo '206 Partial content';;
	'400')	echo '400 Bad request';;
	'401')	echo '401 Unauthorized';;
	'402')	echo '402 Payment required';;
	'403')	echo '403 Forbidden';;
	'404')	echo '404 Not found';;
	'405')	echo '405 Method not allowed';;
	'406')	echo '406 Not acceptable';;
	'407')	echo '407 Proxy authentication required';;
	'408')	echo '408 Request timeout';;
	'409')	echo '409 Conflict';;
	'410')	echo '410 Gone';;
	'411')	echo '411 Length required';;
	'412')	echo '412 Precondition failed';;
	'413')	echo '413 Request entity too large';;
	'414')	echo '414 Request URI too long';;
	'415')	echo '415 Unsupported media type';;
	'416')	echo '416 Requested range';;
	'417')	echo '417 Expectation failed';;
	'418')	echo "418 I'm a teapot";;
	'419')	echo '419 Authentication timeout';;
	'420')	echo '420 Enhance your calm';;
	'426')	echo '426 Upgrade required';;
	'428')	echo '428 Precondition required';;
	'429')	echo '429 Too many requests';;
	'431')	echo '431 Request header fields too large';;
	'451')	echo '451 Unavailable for legal reasons';;
	'500')	echo '500 Internal server error';;
	'501')	echo '501 Not implemented';;
	'502')	echo '502 Bad gateway';;
	'503')	echo '503 Service unavailable';;
	'504')	echo '504 Gateway timeout';;
	'505')	echo '505 HTTP version not supported';;
	'506')	echo '506 Variant also negotiates';;
	'510')	echo '510 Not extended';;
	'511')	echo '511 Network authentication required';;
	*)	echo "${code} (unknown)"
	esac
}


function curl_do () {
	local url
	expect_args url -- "$@"
	shift

	local status code
	status=0
	if ! code=$(
		curl "${url}"                      \
			--fail                     \
			--location                 \
			--silent                   \
			--show-error               \
			--write-out '%{http_code}' \
			"$@"                       \
			2>'/dev/null'
	); then
		status=1
	fi

	local code_description
	code_description=$( echo_http_code_description "${code}" ) || die
	log_end "${code_description}"

	return "${status}"
}


function curl_download () {
	local src_file_url dst_file
	expect_args src_file_url dst_file -- "$@"
	expect_no_existing "${dst_file}"

	log_indent_begin "Downloading ${src_file_url}..."

	local dst_dir
	dst_dir=$( dirname "${dst_file}" ) || die
	mkdir -p "${dst_dir}" || die

	curl_do "${src_file_url}" \
		--output "${dst_file}"
}


function curl_check () {
	local src_url
	expect_args src_url -- "$@"

	log_indent_begin "Checking ${src_url}..."

	curl_do "${src_url}"         \
		--output '/dev/null' \
		--head
}


function curl_upload () {
	local src_file dst_file_url
	expect_args src_file dst_file_url -- "$@"
	expect_existing "${src_file}"

	log_indent_begin "Uploading ${dst_file_url}..."

	curl_do "${dst_file_url}"    \
		--output '/dev/null' \
		--upload-file "${src_file}"
}


function curl_delete () {
	local dst_url
	expect_args dst_url -- "$@"

	log_indent_begin "Deleting ${dst_url}..."

	curl_do "${dst_url}"         \
		--output '/dev/null' \
		--request DELETE
}
