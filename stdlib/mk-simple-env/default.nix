{
	lib,
	stdenvNoCC,
	eza,
	moreutils,
	fd,
	ripgrep,
}: let
	stdenv = stdenvNoCC;

	/**
	 *
	 * Arguments:
	 * - name ? null :: str
	 *	 The derivation name for the derivation `mkSimpleEnv` creates.
	 * - layers :: listOf (coercableTo storePath)
	 *
	 * - nativeBuildInputs ? [ eza moreutils fd ripgrep ] :: listOf (coerceableTo storePath)
	 */
	mkSimpleEnv = {
		name ? null,
		layers,
		nativeBuildInputs ? [
			eza
			moreutils
			fd
			ripgrep
		],
		postInstall ? null,
		/** Extra attributes to pass to `stdenv.mkDerivation`. */
		extraAttrs ? null,
	}: self: {
		name = if name != null then name else mkAutomaticName self.layers;
		strictDeps = true;
		__structuredAttrs = true;

		nativeBuildInputs = [
			./mk-simple-env.sh
		] ++ lib.concatLists [
			nativeBuildInputs
		];

		preHook = ''
			defaultNativeBuildInputs=()
		'';

		/** Disable all standard phases except installPhase */
		dontUnpack = true;
		dontPatch = true;
		dontConfigure = true;
		dontBuild = true;
		doCheck = false;
		dontFixup = true;
		doInstallCheck = false;
		dontDist = true;

		inherit postInstall;

		layers = assert (lib.length layers > 0); layers;
		baseLayer = lib.head self.layers;

		allPaths = lib.foldToList self.layers (acc: layer: lib.concatLists [
			acc
			[ layer ]
			# Propagated build inputs are vaguely special.
			layer.propagatedBuildInputs or [ ]
			# Use `passthru.propagateForSimpleEnv` if exists
			layer.propagateForSimpleEnv or [ ]
		]) |> lib.unique;

		meta = {
			description = "Copied trees starting with ${lib.getName self.baseLayer}";
		};
	};

	mkAutomaticName = layers: let
		first = lib.head layers;
		headName = first.pname or first.name;
		numOtherLayers = (lib.lists.length layers) - 1;
	in "copied-trees-${headName}_${toString numOtherLayers}";

	extendedMkDerivation = fpAttrs: stdenv.mkDerivation (self: let
		# Resolve the fixed point.
		args = if lib.isFunction fpAttrs then fpAttrs self else fpAttrs;

		# Get the boilerplate arguments.
		simpleEnvArgs = mkSimpleEnv args self;

		# And merge them together to get the final arguments to `mkDerivation`.
	in lib.recursiveUpdate simpleEnvArgs args.extraAttrs);


in lib.mirrorFunctionArgs mkSimpleEnv extendedMkDerivation
