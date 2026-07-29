#!/usr/bin/env bash

set -euo pipefail inherit_errexit

# All of these are set in Nix code. Be still, Shellcheck.
: "${script:?}"
: "${dest:?}"
# Checking the length appears to be the most reliable way to check for the existence
# of an associative array which may be empty.
# With `set -u`, this will fail if `substitutions` is not set.
# If we didin't want to exit on unbound, we could use `declare -p`.
[[ -n "${#substitutions[@]}" ]]
[[ -n "${#multilineSubstitutions[@]}" ]]


function performSubstitutions()
{
	local key
	local value
	for key in "${!substitutions[@]}"; do
		value="${substitutions["$key"]}"
		sd --fixed-strings "@${key}@" "$value" "$NIX_BUILD_TOP/setup-hook.sh"
	done

	for key in "${!multilineSubstitutions[@]}"; do
		value="${multilineSubstitutions["$key"]}"
		sd --fixed-strings --across --flags=m "@${key}@" "$value" "$NIX_BUILD_TOP/setup-hook.sh"
	done

	# FIXME: verify no @vars@ left.
}

function showDiff()
{
	if [[ "${#substitutions[@]}" -eq 0 ]]; then
		if [[ "${#multilineSubstitutions[@]}" ]]; then
			return
		fi
	fi

	nixInfoLog "completed substitutions:"
	# diff(1) exits with 1 if the files differ.
	local ret
	ret=0
	diff -u "$NIX_BUILD_TOP/setup-hook.sh.bak" "$NIX_BUILD_TOP/setup-hook.sh" >"$NIX_BUILD_TOP/diff.patch" || ret="$?"
	if [[ "$ret" -gt 1 ]]; then
		nixErrorLog "diff(1) returned non-zero exit code: $ret"
		return "$ret"
	fi
	diffstat "$NIX_BUILD_TOP/diff.patch"
}

# If the script is a file, we copy it.
# If it's just a string, we make into a file.
if [[ -f "$script" ]]; then
	install -Dm644 "$script" "$NIX_BUILD_TOP/setup-hook.sh"
else
	nixInfoLog "treating '\$script' as a string"
	echo "$script" >> "$NIX_BUILD_TOP/setup-hook.sh"
	echo "$script" >> "$NIX_BUILD_TOP/setup-hook.sh.bak"
fi

performSubstitutions
showDiff

install -Dm644 "$NIX_BUILD_TOP/setup-hook.sh" "$dest"
