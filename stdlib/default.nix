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

	mkLldStdenv = qpkgs.callPackage ./mk-lld-stdenv { };

	/** Overrides stdenv, except for stdenvNoCC. */
	overridePkgStdenvCC = { ... }@drv: { ... }@newStdenv: let
		isntNoCC = name: !(lib.strings.hasSuffix "noCC" name);
		stdenvArgs = drv.override
		|> lib.functionArgs
		|> lib.filterAttrs (name: _: lib.isStdenvName name && isntNoCC name)
		|> lib.mapAttrs (_: _: newStdenv);
	in if lib.isFunction drv.override or null then (
		drv.override stdenvArgs
	) else if lib.isFunction drv.overrideAttrs or null then (
		if drv.stdenv.hasCC then (
			newStdenv.mkDerivation drv.drvAttrs
		) else (
			drv
		)
	) else throw "don't know how to override ${drv.drvPath}, sorry";

	/** Returns null if all of them are broken. */
	pkgByFirstWorkingStdenv = stdenvs: assert lib.isList stdenvs; { ... }@pkg: stdenvs
	|> lib.map (self.overridePkgStdenvCC pkg)
	|> lib.lists.findFirst lib.isEnabledDerivation null;

	#overridePkgStdenv = newStdenv: drv: let
	#	overrideArgs = lib.functionArgs drv.override;
	#	stdenvArgs = overrideArgs
	#	|> lib.filterAttrs (name: _: (name == "stdenv") || (lib.strings.hasSuffix "Stdenv" name))
	#	|> lib.mapAttrs (_: _: newStdenv);
	#in if lib.isFunction (drv.override or null) then (
	#	drv.override stdenvArgs
	#) else if lib.isFunction (drv.overrideAttrs or null) then (
	#	throw "unimplemented"
	#) else throw "don't know how to override ${drv.drvPath}, sorry";

})
