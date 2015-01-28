format_http_code_description () {
	local code
	expect_args code -- "$@"

	case "${code}" in
	'100')	echo '100 (continue)';;
	'101')	echo '101 (switching protocols)';;
	'200')	echo 'done';;
	'201')	echo '201 (created)';;
	'202')	echo '202 (accepted)';;
	'203')	echo '203 (non-authoritative information)';;
	'204')	echo '204 (no content)';;
	'205')	echo '205 (reset content)';;
	'206')	echo '206 (partial content)';;
	'300')	echo '300 (multiple choices)';;
	'301')	echo '301 (moved permanently)';;
	'302')	echo '302 (found)';;
	'303')	echo '303 (see other)';;
	'304')	echo '304 (not modified)';;
	'305')	echo '305 (use proxy)';;
	'306')	echo '306 (switch proxy)';;
	'307')	echo '307 (temporary redirect)';;
	'400')	echo '400 (bad request)';;
	'401')	echo '401 (unauthorized)';;
	'402')	echo '402 (payment required)';;
	'403')	echo '403 (forbidden)';;
	'404')	echo '404 (not found)';;
	'405')	echo '405 (method not allowed)';;
	'406')	echo '406 (not acceptable)';;
	'407')	echo '407 (proxy authentication required)';;
	'408')	echo '408 (request timeout)';;
	'409')	echo '409 (conflict)';;
	'410')	echo '410 (gone)';;
	'411')	echo '411 (length required)';;
	'412')	echo '412 (precondition failed)';;
	'413')	echo '413 (request entity too large)';;
	'414')	echo '414 (request URI too long)';;
	'415')	echo '415 (unsupported media type)';;
	'416')	echo '416 (requested range)';;
	'417')	echo '417 (expectation failed)';;
	'418')	echo "418 (I'm a teapot)";;
	'419')	echo '419 (authentication timeout)';;
	'420')	echo '420 (enhance your calm)';;
	'426')	echo '426 (upgrade required)';;
	'428')	echo '428 (precondition required)';;
	'429')	echo '429 (too many requests)';;
	'431')	echo '431 (request header fields too large)';;
	'451')	echo '451 (unavailable for legal reasons)';;
	'500')	echo '500 (internal server error)';;
	'501')	echo '501 (not implemented)';;
	'502')	echo '502 (bad gateway)';;
	'503')	echo '503 (service unavailable)';;
	'504')	echo '504 (gateway timeout)';;
	'505')	echo '505 (HTTP version not supported)';;
	'506')	echo '506 (variant also negotiates)';;
	'510')	echo '510 (not extended)';;
	'511')	echo '511 (network authentication required)';;
	*)	echo "${code} (unknown)"
	esac
}


return_http_code_status () {
	local code
	expect_args code -- "$@"

	case "${code}" in
	'2'*)	return 0;;
	'3'*)	return 3;;
	'4'*)	return 4;;
	'5'*)	return 5;;
	*)	return 1
	esac
}


curl_do () {
	local url
	expect_args url -- "$@"
	shift

	# NOTE: On Debian 6, curl considers HTTP 40* errors to be transient,
	# which makes using the --retry option impractical.  Additionally,
	# in some circumstances, curl writes out 100 and fails instead
	# of automatically continuing.
	# http://curl.haxx.se/mail/lib-2011-03/0161.html
	local max_retries retries code
	max_retries="${BASHMENOT_CURL_RETRIES:-5}"
	retries="${max_retries}"
	code=
	while (( retries )); do
		code=$(
			curl "${url}" \
				--fail \
				--location \
				--silent \
				--show-error \
				--write-out '%{http_code}' \
				"$@" \
				2>'/dev/null'
		) || true

		local code_description
		code_description=$( format_http_code_description "${code}" )
		log_indent_end "${code_description}"

		if [[ "${code}" =~ '2'.* ]]; then
			break
		fi
		if [[ "${code}" =~ '4'.* ]] && ! (( ${BASHMENOT_INTERNAL_CURL_RETRY_ALL:-0} )); then
			break
		fi

		retries=$(( retries - 1 ))
		if (( retries )); then
			local retry delay
			retry=$(( max_retries - retries ))
			delay=$(( 2**retry ))

			log_indent_begin "Retrying in ${delay} seconds (${retry}/${max_retries})..."
			sleep "${delay}" || true
		fi
	done

	return_http_code_status "${code}" || return
}


curl_download () {
	local src_file_url dst_file
	expect_args src_file_url dst_file -- "$@"

	log_indent_begin "Downloading ${src_file_url}..."

	local dst_dir
	dst_dir=$( dirname "${dst_file}" ) || return 1

	mkdir -p "${dst_dir}" || return 1

	curl_do "${src_file_url}" \
		--output "${dst_file}" || return
}


curl_check () {
	local src_url
	expect_args src_url -- "$@"

	log_indent_begin "Checking ${src_url}..."

	curl_do "${src_url}" \
		--output '/dev/null' \
		--head || return
}


curl_upload () {
	local src_file dst_file_url
	expect_args src_file dst_file_url -- "$@"

	expect_existing "${src_file}" || return 1

	log_indent_begin "Uploading ${dst_file_url}..."

	curl_do "${dst_file_url}" \
		--output '/dev/null' \
		--upload-file "${src_file}" || return
}


curl_delete () {
	local dst_url
	expect_args dst_url -- "$@"

	log_indent_begin "Deleting ${dst_url}..."

	curl_do "${dst_url}" \
		--output '/dev/null' \
		--request DELETE || return
}
