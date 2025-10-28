{
	lib,
	strace,
	fetchFromGitHub,
}:

# Strace patched to have colored output.
strace.overrideAttrs (final: prev: {
	# Based on the patch from https://github.com/xfgusta/strace-with-colors
	colorPatches = fetchFromGitHub {
		owner = "Qyriad";
		repo = "strace-with-colors";
		tag = "v6.16";
		hash = "sha256-AqyafSyGnTB0qCP4PkGIhKi0jmQyr3y2FpCnZ5obpNw=";
	};

	# Support NixOS 25.11 and 25.05.
	# I'm going to regret this aren't I.
	"colorPatch_6.15" = final.colorPatches + "/strace-with-colors_v6.15.patch";
	"colorPatch_6.16" = final.colorPatches + "/strace-with-colors_v6.16.patch";
	colorPatch = if lib.versionOlder final.version "6.16" then (
		final."colorPatch_6.15"
	) else (
		final."colorPatch_6.16"
	);

	patches = prev.patches or [ ] ++ [ final.colorPatch ];

	passthru.allowUnstructuredAttrs = true;

	meta = prev.meta // {
		description = prev.meta.description + " (with xfgusta's colors patch)";
	};
})
