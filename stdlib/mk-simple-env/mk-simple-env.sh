#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${allPaths:-}" ]]; then
	echo "$name:" "error: '\$allPaths' is empty" >&2
	exit 1
fi

function mkSimpleEnvBuildPhase()
{
	runHook preInstall

	mkdir -p "$out"

	for pathElem in "${allPaths[@]}"; do
		#nixLog "working on '$pathElem"
		# We're copying store paths, and cp will preserve their read-only nature,
		# but we still need to modify things in "$out".
		chmod -R u+w "$out"

		pushd "$pathElem" > /dev/null

		cp -f --reflink=auto --recursive * "$out"

		popd > /dev/null
	done

	runHook postInstall
}

filesWithShebangsIn()
{
	set -euo pipefail
	# Probably "$out/bin"
	local dirForFilesToSearch="$1"

	local ripgrepOutput
	local -a ripgrepCmd
	ripgrepCmd=("rg" "--files-with-matches" "^#!/.*" "$dirForFilesToSearch")
	ripgrepOutput="$("${ripgrepCmd[@]}")" || {
		# Exit handling.
		local rtcode="$?"
		printf "%s: $ %s\n" "$name" "${ripgrepCmd[*]}" >&2
		echo "$ripgrepOutput" >&2
		return "$rtcode"
	}

	while IFS= read -r fileWithMatch; do
		local firstLine
		firstLine="$(head -1 "$fileWithMatch")"
		if (echo "$firstLine" | rg "^#!/") >/dev/null; then
			echo "$fileWithMatch"
		fi
	done <<< "$ripgrepOutput"
}

if [[ -n "${installPhase:-}" ]]; then
	printf "%s: \x1b[34moverriding previous installPhase:\x1b[0m\n" "$name" >&2
	declare -p installPhase >&2
fi

installPhase=mkSimpleEnvBuildPhase
