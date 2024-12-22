#!/usr/bin/env bash

function goConfigurePhase()
{
	runHook preConfigure

	echo "goConfigurePhase()"
	if [[ -z "${goModules:-}" ]]; then
		echo "goConfigurePhase: \$goModules must be set, use 'buildGoModules' nix function"
		exit 1
	fi

	export GOCACHE="$TMPDIR/go-cache"
	export GOPATH="$TMPDIR/go"
	export GOPROXY=off
	export GOSUMDB=off

	rm -rf vendor
	cp -r --reflink=auto "$goModules" vendor

	if [[ "$NIX_HARDENING_ENABLE" =~ "pie" ]]; then
		prependToVar GOFLAGS "buildmode=pie"
	fi

	if [[ -n "${modRoot:-}" ]]; then
		cd "$modRoot"
	fi

	runHook postConfigure
}

if [[ -z "${dontUseGoConfigure:-}" && -z "${configurePhase:-}" ]]; then
	configurePhase="goConfigurePhase"
fi
