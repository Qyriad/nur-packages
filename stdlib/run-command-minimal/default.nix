{
	lib,
	stdenvNoCC,
}: let
	stdenv = stdenvNoCC;

	runCommandMinimal = name: attrs: text: self: {
		inherit name;
		strictDeps = true;
		__structuredAttrs = true;

		enableParallelBuilding = true;
		preferLocalBuild = true;

		preHook = (attrs.preHook or "") + "\n" + ''
			defaultNativeBuildInputs=()
		'';

		buildCommand = text;

		passAsFile = attrs.passAsFile or [ ] ++ [
			"buildCommand"
		];

		# XXX: meta.pos

	} // attrs;

	extendedMkDerivation = name: fpAttrs: text: stdenv.mkDerivation (self: let
		# Resolve the fixed point.
		args = if lib.isFunction fpAttrs then fpAttrs self else fpAttrs;
	in runCommandMinimal name args text self);

in lib.mirrorFunctionArgs runCommandMinimal extendedMkDerivation
