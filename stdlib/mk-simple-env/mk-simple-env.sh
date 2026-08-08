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
		#nixLog "working on '$pathElem'"
		# We're working on store paths, and cp will preserve their read-only nature,
		# but we still need to modify things in "$out".
		# We do this every time, since each iteration might've added more read-only things.
		# We don't use --no-preserve=mode to not clobber other mode bits.
		chmod -R u+w "$out"
		pushd "$pathElem" > /dev/null

		cp -f --reflink=auto --recursive --no-preserve=links --dereference * "$out"

		popd > /dev/null
	done

	runHook postInstall
}

if [[ -n "${installPhase:-}" ]]; then
	printf "%s: \x1b[34moverriding previous installPhase:\x1b[0m\n" "$name" >&2
	declare -p installPhase >&2
fi

installPhase=mkSimpleEnvBuildPhase
