#!/usr/bin/env bash

export ANSI_BOLD="$(printf "\e[1m")"
export ANSI_FAINT="$(printf "\e[2m")"
export ANSI_ITALIC="$(printf "\e[3m")"
export ANSI_RESET="$(printf "\e[0m")"
export ANSI_RED="$(printf "\e[31m")"
export ANSI_GREEN="$(printf "\e[32m")"
export ANSI_YELLOW="$(printf "\e[33m")"
export ANSI_BLUE="$(printf "\e[34m")"
export ANSI_MAGENTA="$(printf "\e[35m")"
export ANSI_CYAN="$(printf "\e[36m")"

function hlBash()
{
	if ! command -v "bat" >/dev/null 2>&1; then
		printf "%s" "$*"
	fi

	printf "%s" "$*" | bat -l bash --style=plain --paging=never --color=always
}

function _nixLogWithLevel()
{
	[[ -z ${NIX_LOG_FD-} || ${NIX_DEBUG:-0} -lt ${1:?} ]] && return 0

	local logLevel
	case "${1:?}" in
	0) logLevel="$ANSI_RED" ;;
	1) logLevel="$ANSI_YELLOW" ;;
	2) logLevel="$ANSI_CYAN" ;;
	3) logLevel="$ANSI_GREEN" ;;
	4) logLevel="$ANSI_GREEN" ;;
	5) logLevel="$ANSI_MAGENTA" ;;
	6) logLevel="$ANSI_FAINT" ;;
	7) logLevel="$ANSI_FAINT$ANSI_ITALIC" ;;
	*)
		echo "_nixLogWithLevel: called with invalid log level: ${1:?}" >&"$NIX_LOG_FD"
		return 1
		;;
	esac

	printf "%s::\e[0m %s\n" "$logLevel" "${2:?}" >&"$NIX_LOG_FD"
}

#function _joinNewlines()
#{
#	local line
#	local output
#	while IFS= read -r line; do
#		line="${line#"${line%%[![:space:]]*}"}"
#		if [[ -n "$line" ]]; then
#			output+="$line "
#		fi
#	done <<< "$*"
#
#	echo -n "$output"
#}

function ninja()
{
	TERM=xterm command ninja "$@" | cat
}

function _logHook()
{
	# Fast path in case nixTalkativeLog is no-op.
	if [[ -z ${NIX_LOG_FD-} ]]; then
		return
	fi

	local hookKind="$1"
	local hookExpr="$2"
	shift 2

	if declare -F "$hookExpr" > /dev/null 2>&1; then
		nixTalkativeLog "${ANSI_FAINT}calling '${ANSI_RESET}$hookKind' ${ANSI_FAINT}function hook${ANSI_RESET} '${ANSI_CYAN}$hookExpr${ANSI_RESET}'" "$@"
		#echo "$(hlBash "$(declare -f "$hookExpr" | tail -n+2)")"

	elif type -p "$hookExpr" > /dev/null; then
		nixTalkativeLog "sourcing '$hookKind' script hook '$hookExpr'"

	elif [[ "$hookExpr" != "_callImplicitHook"* ]]; then
		# Here we have a string hook to eval.
		# Join lines onto one with literal \n characters unless NIX_DEBUG >= 5.
		local exprToOutput
		if [[ ${NIX_DEBUG:-0} -ge 5 ]]; then
			exprToOutput="$hookExpr"
		else
			# We have `r'\n'.join([line.lstrip() for lines in text.split('\n')])` at home.
			local hookExprLine
			while IFS= read -r hookExprLine; do
				# These lines often have indentation,
				# so let's remove leading whitespace.
				hookExprLine="${hookExprLine#"${hookExprLine%%[![:space:]]*}"}"
				# If this line wasn't entirely whitespace,
				# then add it to our output
				if [[ -n "$hookExprLine" ]]; then
					exprToOutput+="$hookExprLine\\n "
				fi
			done <<< "$hookExpr"

			# And then remove the final, unnecessary, \n
			exprToOutput="${exprToOutput%%\\n }"
		fi
		local exprHl
		exprHl="$(hlBash "$exprToOutput")"
		nixTalkativeLog "${ANSI_FAINT}evaling '${ANSI_RESET}$hookKind' ${ANSI_FAINT}string hook '${ANSI_RESET}${exprHl}${ANSI_FAINT}'"
	fi
}
