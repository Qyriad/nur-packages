#!/usr/bin/env bash

function goInstallPhase()
{
	runHook preInstall

	mkdir -p "$out"
	bindir="$GOPATH/bin"
	if [[ -e "$bindir" ]]; then
		cp -rv "$bindir" "$out"
	fi

	runHook postInstall
}

if [[ -z "${dontUseGoInstall:-}" && -z "${installPhase:-}" ]]; then
	installPhase="goInstallPhase"
fi

