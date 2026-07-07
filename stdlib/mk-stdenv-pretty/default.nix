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

	preHook = lib.concatStringsSep "\n" [
		"source ${prettyPreHook}"
		"${prev.preHook or ""}"
	];

	postHook = lib.concatStringsSep "\n" [
		"source ${prettyPostHook}"
		"${prev.postHook or ""}"
	];
})
