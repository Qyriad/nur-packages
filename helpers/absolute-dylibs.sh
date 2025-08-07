#!/usr/bin/env bash

function makeDylibsAbsolute()
{
	(
		set -euo pipefail
		if [[ "${dontMakeDylibsAbsolute:-}" == "1" ]]; then
			return
		fi

		echo "making dynamic library references absolute"

		@body@
	)
}

postFixupHooks+=(makeDylibsAbsolute)
