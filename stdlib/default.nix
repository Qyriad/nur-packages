/**
 * qpkgs stdlib, in contrast with `lib`, is for functions tied to `pkgs`.
 */
{
	qpkgs ? import ../default.nix { },
	lib ? qpkgs.lib,
}: lib.makeExtensible (self: {
	runCommandMinimal = qpkgs.callPackage ./run-command-minimal { };

	# FIXME: can we hack something to make `meta.position` work?
	mkSimpleEnv = qpkgs.callPackage ./mk-simple-env { };

	mkStdenvPretty = qpkgs.callPackage ./mk-stdenv-pretty { };
})
