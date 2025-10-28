function showPhaseHeader()
{
	local phase="$1"

	local realPhase
	local logCmd
	local logPrefix

	local fullMsg

	if [[ -n "${!phase:-}" ]]; then
		realPhase="${!phase}"
		logCmd="nixInfoLog"

		local prefixPart
		prefixPart="${ANSI_FAINT}Running custom ${ANSI_RESET}$phase${ANSI_FAINT}: "
		local phasePart
		phasePart="'${ANSI_CYAN}$realPhase${ANSI_RESET}${ANSI_FAINT}'"
		fullMsg="$prefixPart${ANSI_RESET}$phasePart${ANSI_RESET}"

	else
		realPhase="$phase"
		logCmd="nixTalkativeLog"

		fullMsg="${ANSI_FAINT}Running phase: ${ANSI_RESET}${ANSI_CYAN}$phase${ANSI_RESET}"
	fi

	"$logCmd" "$fullMsg"

	if [[ -z "${NIX_LOG_FD:-}" ]]; then
		return
	fi

	printf '@nix { "action": "setPhase", "phase": "%s" }\n' "$phase" >&"$NIX_LOG_FD"
}

showPhaseFooter()
{
	local phase="$1"
	local startTime="$2"
	local endTime="$3"
	local delta=$(( endTime - startTime ))
	(( delta < 30 )) && return

	local H=$((delta/3600))
	local M=$((delta%3600/60))
	local S=$((delta%60))
	echo -n "$phase completed in "
	(( H > 0 )) && echo -n "$H hours "
	(( M > 0 )) && echo -n "$M minutes "
	echo "$S seconds"
}

if [[ -z "${NIX_DEBUG:-}" ]]; then
	NIX_DEBUG=4
fi
