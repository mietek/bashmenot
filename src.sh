set -o pipefail

export BASHMENOT_TOP_DIR
BASHMENOT_TOP_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )

source "${BASHMENOT_TOP_DIR}/src/log.sh"
source "${BASHMENOT_TOP_DIR}/src/expect.sh"
source "${BASHMENOT_TOP_DIR}/src/os.sh"
source "${BASHMENOT_TOP_DIR}/src/quote.sh"
source "${BASHMENOT_TOP_DIR}/src/line.sh"
source "${BASHMENOT_TOP_DIR}/src/sort.sh"
source "${BASHMENOT_TOP_DIR}/src/date.sh"
source "${BASHMENOT_TOP_DIR}/src/file.sh"
source "${BASHMENOT_TOP_DIR}/src/tar.sh"
source "${BASHMENOT_TOP_DIR}/src/curl.sh"
source "${BASHMENOT_TOP_DIR}/src/s3.sh"


bashmenot_autoupdate () {
	if (( ${BASHMENOT_NO_AUTOUPDATE:-0} )); then
		return 0
	fi

	if [[ ! -d "${BASHMENOT_TOP_DIR}/.git" ]]; then
		return 1
	fi

	local urloid url branch
	urloid="${BASHMENOT_URL:-https://github.com/mietek/bashmenot}"
	url="${urloid%#*}"
	branch="${urloid#*#}"
	if [[ "${branch}" == "${url}" ]]; then
		branch='master'
	fi

	local git_url
	git_url=$( cd "${BASHMENOT_TOP_DIR}" && git config --get 'remote.origin.url' ) || return 1
	if [[ "${git_url}" != "${url}" ]]; then
		( cd "${BASHMENOT_TOP_DIR}" && git remote set-url 'origin' "${url}" ) || return 1
	fi

	log_begin 'Auto-updating bashmenot...'

	local commit_hash
	commit_hash=$(
		cd "${BASHMENOT_TOP_DIR}" &&
		git fetch -q 'origin' &&
		git reset -q --hard "origin/${branch}" &&
		git log -n 1 --pretty='format:%h'
	) || return 1
	log_end "done (${commit_hash})"

	BASHMENOT_NO_AUTOUPDATE=1 \
		source "${BASHMENOT_TOP_DIR}/src.sh" || return 1
}


if ! bashmenot_autoupdate; then
	log_warning 'Cannot auto-update bashmenot'
fi
