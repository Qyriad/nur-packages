#!/usr/bin/env bash

function cargoDefaultsHook()
{
	echo "cargoDefaultsHook()"

	if [[ -z "${cargoBuildType:-}" ]]; then
		export cargoBuildType="release"
	fi

	if [[ -z "${cargoCheckType:-}" ]]; then
		export cargoCheckType="test"
	fi
}

if [[ -z "${dontSetCargoDefaults:-}" ]]; then
	postUnpackHooks+=(cargoDefaultsHook)
fi
