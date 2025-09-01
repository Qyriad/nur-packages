#!/usr/bin/env bash

function patchCmd()
{
	(
		set -euo pipefail
		@patchCmdBody@
	)
}

function patchForDylib()
{
	(
		set -euo pipefail
		local patchTarget
		local dylibPath

		dylibPath="$1"
		patchTarget="$2"

		if ! [[ -f "$patchTarget" ]]; then
			echo "@hookName@: patch target file '$patchTarget' not found"
			exit 1
		fi

		if ! [[ -f "$dylibPath" ]]; then
			echo "@hookName@: dylib path '$dylibPath' for '$patchTarget' not found"
			exit 1
		fi

		patchCmd "$dylibPath" "$patchTarget"
	)
}

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
