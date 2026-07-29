#!/usr/bin/env bash

# Based on build-grammar.nix

function treeSitterXonshConfigurePhase()
{
	runHook preConfigure

	set -euo pipefail

	local treeSitterJson
	treeSitterJson="${treeSitterJson:-$NIX_BUILD_TOP/$sourceRoot/tree-sitter.json}"

	if ! [[ -e "$treeSitterJson" ]]; then
		echo "No tree-sitter.json; aborting"
		(set -x ; pwd ; ls -lah --color=always)
		return 1
	fi

	local grammar
	grammar="$(jq -c 'first(.grammars[] | select(.name == env.language))' "$treeSitterJson")"

	# Move to the appropriate working directory for build.
	local grammarWorkdir
	grammarWorkdir="$(jq -r '.path // "."' <<< "$grammar")"
	declare -p grammarWorkdir
	cd -- "$grammarWorkdir"

	runHook postConfigure
}

if [[ -z "${dontUseTreeSitterXonshConfigure:-}" && -z "${configurePhase:-}" ]]; then
	configurePhase=treeSitterXonshConfigurePhase
fi
