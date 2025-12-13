{
	pkgs,
	lib,
	stdenvAdapters,
	llvmPackages,
}: let
	inherit (builtins) tryEval;

	toplevelStdenvs = pkgs
	|> lib.filterAttrs (name: _: lib.strings.hasSuffix "Stdenv" name)
	|> lib.filterAttrs (_: stdenv: let
		isStdenv = lib.isAttrs stdenv && stdenv ? mkDerivation;
		# Many things with stdenv-like names are actually just throws.
		canInstantiate = stdenv.outPath != null;
	in lib.tryResOr (tryEval (isStdenv && canInstantiate)) false);

	extraStdenvs = {
		# This one just Isn't provided by Nixpkgs for whatever reason.
		clangLldStdenv = llvmPackages.stdenv.cc.override {
			bintools = llvmPackages.bintools;
		}
		|> stdenvAdapters.overrideCC llvmPackages.stdenv
		|> stdenvAdapters.addAttrsToDerivation {
			mesonFlags = [
				"-Dc_link_args=-fuse-ld=lld"
				"-Dcpp_link_args=-fuse-ld=lld"
			];
			cmakeFlags = [
				"-DCMAKE_EXE_LINKER_FLAGS_INIT=-fuse-ld=lld"
				"-DCMAKE_SHARED_LINKER_FLAGS_INIT=-fuse-ld=lld"
				"-DCMAKE_STATIC_LINKER_FLAGS_INIT=-fuse-ld=lld"
				"-DCMAKE_MODULE_LINKER_FLAGS_INIT=-fuse-ld=lld"
			];
		};
	};

	baseStdenvs = toplevelStdenvs // extraStdenvs;

	staticStdenvs = baseStdenvs
	|> lib.mapAttrs' (name: stdenv: {
		name = lib.strings.replaceStrings [ "Stdenv" ] [ "StaticStdenv" ] name;
		value = stdenvAdapters.makeStatic stdenv;
	});

in { ... }: lib.mergeAttrsList [
	baseStdenvs
	staticStdenvs
]
