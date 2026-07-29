#!/usr/bin/env bash

declare -A replaceFiles

function replaceFilesHook()
{
	set -euo pipefail

	: "${sourceRoot:?specify sourceRoot to replace files relative to}"

	if [[ "${#replaceFiles[@]}" -eq 0 ]]; then
		nixWarnLog "replace-files-hook: no replacements specified"
		return
	fi

	local key
	local value
	for key in "${!replaceFiles[@]}"; do
		value="${replaceFiles["$key"]}"
		local dest="$NIX_BUILD_TOP/$sourceRoot/$key"
		local replacement="$value"
		if [[ -e "$dest" ]]; then
			rm -f "$dest"
			cp -f "$replacement" "$dest"
			nixInfoLog "replace-files-hook: replaced '$key'"
		else
			cp "$replacement" "$dest"
			nixInfoLog "replace-files-hook: created '$key'"
		fi
	done
}

if [[ -z "${dontReplaceFiles:-}" ]]; then
	postPatchHooks+=(replaceFilesHook)
fi
