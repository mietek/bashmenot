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
	urloid="${BASHMENOT_URL:-https://github.com/mietek/bashmenot.git}"
	url="${urloid%#*}"
	branch="${urloid#*#}"
	if [[ "${branch}" == "${url}" ]]; then
		branch='master'
	fi

	log 'Auto-updating bashmenot'

	local git_url must_update
	must_update=0
	git_url=$( git -C "${BASHMENOT_TOP_DIR}" ls-remote --get-url 'origin' ) || return 1
	if [[ "${git_url}" != "${url}" ]]; then
		git -C "${BASHMENOT_TOP_DIR}" remote set-url 'origin' "${url}" |& quote || return 1
		must_update=1
	fi

	if ! (( must_update )); then
		local mark_time current_time
		mark_time=$( get_modification_time "${BASHMENOT_TOP_DIR}" ) || return 1
		current_time=$( date +'%s' ) || return 1
		if (( mark_time > current_time - 60 )); then
			return 0
		fi
	fi

	git -C "${BASHMENOT_TOP_DIR}" fetch 'origin' |& quote || return 1
	git -C "${BASHMENOT_TOP_DIR}" reset --hard "origin/${branch}" |& quote || return 1

	BASHMENOT_NO_AUTOUPDATE=1 \
		source "${BASHMENOT_TOP_DIR}/src.sh" || return 1
}


if ! bashmenot_autoupdate; then
	log_warning 'Cannot auto-update bashmenot'
fi
