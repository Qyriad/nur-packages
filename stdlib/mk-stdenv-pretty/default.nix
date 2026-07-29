{
	lib,
	bat,
	replaceVars,
	stdlib,
}: let
	inherit (stdlib.stdenvPrettyHooks) prettyPreHook prettyPostHook;
in pkg: pkg.overrideAttrs (prev: {
	nativeBuildInputs = prev.nativeBuildInputs or [ ] ++ [
		bat
	];

	preHook = lib.concatNonemptyStringsSep "\n" [
		"source ${prettyPreHook}"
		"${prev.preHook or ""}"
	];

	postHook = lib.concatNonemptyStringsSep "\n" [
		"source ${prettyPostHook}"
		"${prev.postHook or ""}"
	];
})
