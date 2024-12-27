#!/usr/bin/env bash

function fetchGoModulesBuildPhase()
{
	runHook preBuild

	echo "$name: fetchGoModulesBuildPhase()"

	if [[ -n "${deleteVendor:-}" ]]; then
		if [[ -d "vendor" ]]; then
			echo "$name: deleting existing 'vendor' directory"
			rm -rf "./vendor"
		else
			echo "$name: 'deleteVendor' specified but 'vendor' directory does not exist"
			exit 1
		fi
	fi

	go mod vendor "${goModVendorFlags[@]}"

	mkdir -p "vendor"

	runHook postBuild
}

if [[ -z "${dontUseFetchGoModulesBuild:-}" && -z "${buildPhase:-}" ]]; then
	buildPhase="fetchGoModulesBuildPhase"
fi
