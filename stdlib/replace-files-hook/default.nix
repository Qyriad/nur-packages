{
	lib,
	stdlib,
	# FIXME?: take stdenv instead?
	stdenvNoCC,
}: stdlib.mkSetupHook stdenvNoCC (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	name = "replace-files-hook";

	script = ./replace-files-hook.sh;

	# TODO: implement.
	#passthru.__functor = _: {
	#	...
	#}@substitutions:

	meta = {
		description = "A setup hook replace entire files in patchPhase";
		longDescription = lib.dedent ''
			During postPatchHooks, replaces all files keyed by attributes in `replaceFiles` with their values.
			Values are paths to a file; that file is copied over into the replacement path.

			Replacements are relative to $sourceRoot.

			Arguments:
				- replaceFiles: attrset of path | string
				- dontReplaceFiles: if set to a non-empty value, does not add replaceFilesHook to postPatchHooks.
		'';
	};
})
