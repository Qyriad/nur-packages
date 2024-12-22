#!/usr/bin/env bash

function buildGoDir()
{
	local cmd
	cmd="$1"
	dir="$2"

	appendToVar goFlags "-p"
	appendToVar goFlags "$NIX_BUILD_CORES"

	if [[ "$cmd" = "test" ]]; then
		appendToVar goFlags "-vet=off"
		appendToVar goFlags "${checkFlags[@]}"
	fi

	local -a flagsArray
	concatTo flagsArray goFlags goFlagsArray

	local OUT
	if ! OUT="$(go "$cmd" "${flagsArray[@]}" "$dir" 2>&1)"; then
		if ! echo "$OUT" | grep -qE '(no( buildable| non-test)?|build constraints exclude all) Go source )?files'; then
			echo "$OUT" >&2
			return 1
		fi
	fi

	echo "$OUT" >&2
	if [[ -n "$OUT" ]]; then
		:
	fi

	return 0
}

function goBuildPhase()
{
	runHook preBuild

	echo "goBuildPhase()"
	exclude='\(/_\|examples\|Godeps\|testdata'
	if [[ -n "$excludedPackages" ]]; then
		IFS=' ' read -r -a excludedArr <<<$excludedPackages
		printf -v "excludedAlternates" '%s\\|' "${excludedArr[@]}"
		# drop final "\|" added by printf
		excludedAlternates="${excludedAlternates%'\|'}"
		exclude+='\|'"$excludedAlternates"
	fi
	exclude+='\)'

	if (( "${NIX_DEBUG:-0}" >= 1)); then
		appendToVar flags "-x"
	fi

	if [[ -z "${enableParallelBuilding:-}" ]]; then
		export NIX_BUILD_CORES=1
	fi

	for pkg in $(getGoDirs ""); do
		echo "Building subpackage" "$pkg"
		buildGoDir install "$pkg"
	done

	if [[ -n "@hostAndBuildPlatformsDiffer@" ]]; then
		# Normalize cross compiled builds w.r.t. native builds.
		(
			dir="$GOPATH/bin/@GOOS@_@GOARCH@"
			contents="$(shopt -s nullglob; echo "$dir/"*)"
			if [[ -n "$contents" ]]; then
				mv "$dir/"* "$dir/.."
			fi

			if [[ -d "$dir" ]]; then
				rmdir "$dir"
			fi
		)
	fi

	runHook postBuild
}

function getGoDirs()
{
	local type
	type="$1"
	if [[ -n "${subPackages:-}" ]]; then
		echo "$subPackages" | sed "s,\(^\| \),\1./,g"
	else
		find . -type f -name "*$type.go" -exec dirname "{}" ";" | grep -v "/vendor/" | sort --unique | grep -v "$exclude"
	fi
}

if [[ -z "${dontUseGoBuild:-}" && -z "${buildPhase:-}" ]]; then
	buildPhase="goBuildPhase"
fi
