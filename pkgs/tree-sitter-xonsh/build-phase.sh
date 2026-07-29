#!/usr/bin/env bash

# Based on build-grammar.nix

declare -a cflagsArray

: "${isWasi:?missing argument, aborting.}"

function treeSitterXonshBuildPhase()
{
	runHook preBuild

	set -euo pipefail

	tree-sitter generate

	: "${CFLAGS:=}"

	local -a flagsArray=()
	concatTo flagsArray cflagsArray CFLAGS

	"$CC" -fPIC -c src/scanner.c -o scanner.o "${flagsArray[@]}"
	"$CC" -fPIC -c src/parser.c -o parser.o "${flagsArray[@]}"

	if [[ "${isWasi}" -eq "1" ]]; then
		:
	fi

	runHook postBuild
}

if [[ -z "${dontUseTreeSitterXonshBuild:-}" && -z "${configurePhase:-}" ]]; then
	configurePhase=treeSitterXonshBuildPhase
fi
