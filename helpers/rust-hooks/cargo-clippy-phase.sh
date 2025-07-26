#!/usr/bin/env bash

function cargoClippyPhase()
{
	echo "cargoClippyPhase()"

	if [[ -z "${cargoClippyType:-}" ]]; then
		export cargoClippyType="${cargoCheckType:-test}"
	fi

	# We guard against *unset* cargoClippyFlags, but not *empty* cargoClippyFlags.
	if [[ -z "${cargoClippyFlags:}" ]]; then
		local -a cargoClippyFlags=("--deny" "warnings")
	fi

	cargo clippy --all-targets --profile "$cargoClippyType" -- "${cargoClippyFlags[@]}"
}

if [[ -n "${doCargoClippy:-}" ]]; then
	appendToVar preInstallPhases cargoClippyPhase
fi
