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

	getStdenvs = qpkgs.callPackage ./get-stdenvs { };

	overridePkgStdenv = newStdenv: drv: let
		overrideArgs = lib.functionArgs drv.override;
		stdenvArgs = overrideArgs
		|> lib.filterAttrs (name: name == "stdenv" || lib.strings.hasSuffix "Stdenv" name)
		|> lib.mapAttrs (_: newStdenv);
	in if lib.isFunction (drv.override or null) then (
		drv.override stdenvArgs
	) else if lib.isFunction (drv.overrideAttrs or null) then (
		throw "unimplemented"
	) else throw "don't know how to override ${drv.drvPath}, sorry";

})
