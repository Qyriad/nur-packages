#!/usr/bin/env bash

function _doesVarHaveAttribute()
{
	local -
	set -euo pipefail

	: "${1:?_doesVarHaveAttribute: unset \$1: name of variable to check}"
	# shellcheck disable=SC2034
	local -n varRef="$1"

	: "${2:?_doesVarHaveAttribute: unset \$2: attribute to check for}"
	local attr="$2"
	if [[ "${#attr}" -ne 1 ]]; then
		echo "_doesVarHaveAttribute: \$2 must be a single flag, not '$attr'" >&2
		exit 22 # EINVAL
	fi

	# @a on a nameref to an array does actually work, but has some caveats.
	# If the array is empty, then `${varRef@a}` is considered unbound by `set -u`.
	# That's fixable with `${varRef[@]@a}` or `${varRef[*]@a}`, but those expand
	# to the flags of the array variable times the length of the array.
	# So we use indirect expansion with @a instead.
	local flagsOfVar="${!varRef@a}"

	if [[ "${flagsOfVar//"$attr"/}" != "$flagsOfVar" ]]; then
		printf "1"
	fi
}

# Outputs "1" if the named variable is a (non-associative) array.
# Outputs nothing otherwise.
function _isVarArray()
{
	local -
	set -euo pipefail

	: "${1:?_isVarArray: unset \$1: name of variable to check}"
	# shellcheck disable=SC2034
	local -n arrVarRef="$1"

	_doesVarHaveAttribute arrVarRef "a"
}

# Outputs "1" if the named variable is exported.
# Outputs nothing otherwise.
function _isVarExported()
{
	local -
	set -euo pipefail

	: "${1:?_isVarExported: unset \$1: name of variable to check}"
	local xVarName="$1"
	# shellcheck disable=SC2034
	local -n xVarRef="$xVarName"

	_doesVarHaveAttribute xVarRef "x"
}

function _removeVarDirsFromWrapperArgs()
{
	local -
	set -euo pipefail

	local r

	: "${1:?_removeVarDirsFromWrapperArgs: unset \$1: dirs variable name (e.g.: XDG_DATA_DIRS)}"
	: "${2:?_removeVarDirsFromWrapperArgs: unset \$2: wrapper args varname (e.g.: qtWrapperArgs)}"
	: "${3:?_removeVarDirsFromWrapperArgs: unset \$3: removed dirs out var name}"
	local dirsVar="$1"

	local -n wrapperArgs="$2"
	r="$(_isVarArray wrapperArgs)"
	if [[ -z "${r:-}" ]]; then
		echo "_removeVarDirsFromWrapperArgs: \$2 should be an array variable" >&2
		exit 22 # EINVAL
	fi
	# It should also be non-empty, probably.
	if [[ "${#wrapperArgs[@]}" -eq 0 ]]; then
		echo "_removeVarDirsFromWrapperArgs: \$2 should be a non-empty array variable" >&2
		exit 22 # EINVAL
	fi

	local -n removedDirsOut="$3"
	r="$(_isVarArray removedDirsOut)"
	if [[ -z "${r:-}" ]]; then
		echo "_removeVarDirsFromWrapperArgs: \$3 should be an array out-variable" >&2
		exit 22 # EINVAL
	fi
	# It's also an array variable, so it should also be empty.
	if [[ "${#removedDirsOut[@]}" -ne 0 ]]; then
		echo "_removeVarDirsFromWrapperArgs: \$3 should be an empty array out-variable"
		# Like "declare -p" but works through namerefs.
		echo "${removedDirsOut[@]@A}" >&2
		exit 22 # EINVAL
	fi

	local -a savedWrapperArgs
	savedWrapperArgs=("${wrapperArgs[@]}")

	local -a newWrapperArgs
	local -a buffer

	for wrapperArgIdx in "${!savedWrapperArgs[@]}"; do
		local wrapperArg
		wrapperArg="${savedWrapperArgs["$wrapperArgIdx"]}"

		if [[ "$wrapperArg" = "--prefix" ]]; then
			if [[ -n "${buffer[*]}" ]]; then
				newWrapperArgs+=("${buffer[@]}")
				buffer=()
			fi
			buffer+=("$wrapperArg")
			continue
		elif [[ "${buffer[*]}" = "--prefix" ]] && [[ "$wrapperArg" = ":" ]]; then
			buffer+=("$wrapperArg")
			continue
		elif [[ "${buffer[*]}" = "--prefix $dirsVar" ]] && [[ "$wrapperArg" = "$dirsVar" ]]; then
			buffer+=("$wrapperArg")
			continue
		elif [[ "${buffer[*]}" = "--prefix $dirsVar :" ]]; then
			buffer=()
			removedDirsOut+=("$wrapperArg")
			continue
		fi

		buffer+=("$wrapperArg")
	done

	newWrapperArgs+=("${buffer[@]}")
	wrapperArgs=("${newWrapperArgs[@]}")
}

# $1: name of exported variable to find in wrapper args and consolidate. e.g.: "XDG_DATA_DIRS"
# $2: name of wrapper args array variable to find `--prefix "$1"` invocations in and remove them.
#	e.g.: "qtWrapperArgs"
# $3: directory to symlink-farm the directories from the directories found in `$2` into.
#	e.g.: "$out/share"
function consolidateFromWrapperIntoDir()
{
	local -
	set -euo pipefail

	local r

	echo "consolidateDirsFromWrapperArgsHook: consolidating '$1' entries from '$2' into '$3'"

	#
	# Begin argument validation.
	#

	: "${1:?consolidateFromWrapperIntoDir: unset \$1: dirs variable name (e.g.: XDG_DATA_DIRS)}"
	local dirsVar="$1"
	#local -n dirsRef="$dirsVar"

	: "${2:?consolidateFromWrapperIntoDir: unset \$2: wrapper args variable name (e.g.: qtWrapperArgs)}"
	local wrapperArgsVar="$2"
	local -n wrapperArgsRef="$wrapperArgsVar"
	r="$(_isVarArray wrapperArgsRef)"
	if [[ -z "${r:-}" ]]; then
		echo "consolidateFromWrapperIntoDir: \$2 should be an arrayy variable" >&2
		exit 22 # EINVAL
	fi
	# It should also be non-empty, probably.
	if [[ "${#wrapperArgsRef[@]}" -eq 0 ]]; then
		echo "consolidateFromWrapperIntoDir: \$2 should be a non-empty array variable" >&2
		exit 22
	fi

	: "${3:?consolidateFromWrapperIntoDir: unset \$3: symlink-farm destination directory}"
	local dest="$3"
	# It should also already exist, probably?
	# FIXME: should it? or should we make it for them?
	if ! [[ -d "$dest" ]]; then
		echo "consolidateFromWrapperIntoDir: \$3 should be an existing directory ('$dest')" >&2
		exit 20 # ENOTDIR
	fi

	#
	# End argument validation.
	#

	local -a removedDirs=()
	_removeVarDirsFromWrapperArgs "$dirsVar" wrapperArgsRef removedDirs
	for entryIdx in "${!removedDirs[@]}"; do
		local entry="${removedDirs["$entryIdx"]}"
		if ! [[ -d "$entry" ]]; then
			echo "consolidateFromWrapperIntoDir: entry ($entryIdx) '$entry' is not a directory" >&2
			exit 20 # ENOTDIR
		fi
		if [[ "$entry" = "$dest" ]]; then
			nixWarnLog "consolidateFromWrapperIntoDir: skipping wrapper args entry that is itself dest=$dest"
			continue
		fi
		lndir -silent "$entry" "$dest"
		chmod --recursive u+w "$dest"
	done
	# We've removed all the `--prefix` arguments for "$dirsVar".
	# So now it's time to add the consolidated one:
	wrapperArgs+=("--prefix" "$dirsVar" ":" "$dest")
}
