{
	pkgs,
	lib,
  stdlib,
	stdenvAdapters,
	llvmPackages,
}: let
	inherit (builtins) tryEval;

	toplevelStdenvs = pkgs
	|> lib.filterAttrs (name: _: lib.strings.hasSuffix "Stdenv" name)
	|> lib.filterAttrs (_: stdenv: let
		isStdenv = lib.isAttrs stdenv && lib.isFunction stdenv.mkDerivation or null;
		# Many things with stdenv-like names are actually just throws.
		canInstantiate = stdenv.outPath != null;
	in lib.tryResOr (tryEval (isStdenv && canInstantiate)) false);

	extraStdenvs = {
		# This one just Isn't provided by Nixpkgs for whatever reason.
		clangLldStdenv = stdlib.mkLldStdenv { stdenv = llvmPackages.stdenv; };
    libcxxLldStdenv = stdlib.mkLldStdenv { stdenv = llvmPackages.libcxxStdenv; };
	};

	baseStdenvs = toplevelStdenvs // extraStdenvs;

	staticStdenvs = baseStdenvs
	|> lib.mapAttrs' (name: stdenv: {
		name = lib.strings.replaceStrings [ "Stdenv" ] [ "StaticStdenv" ] name;
		value = stdenvAdapters.makeStatic stdenv;
	});

in { }: lib.mergeAttrsList [
	baseStdenvs
	staticStdenvs
]
