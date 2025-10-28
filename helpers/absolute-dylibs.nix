{
	stdenvNoCC,
	lib,
	makeSetupHook,
	patchelf,
	writeShellScript,
}: ({
	name,
	/** attrs of string to list, where each attr name is a (shell expanded) path to patch,
	and each corresponding value is a list of absolute library paths to add.
	*/
	runtimeDependenciesFor,
}: let
	inherit (stdenvNoCC) hostPlatform;

	hookName = "absolute-dylibs-hook-${name}";

	# Type check.
	runtimeDependenciesFor' = runtimeDependenciesFor
	|> lib.mapAttrs (name: value: assert lib.isList value; value)
	|> lib.mapAttrs (name: lib.map (item: assert lib.isString item; item));

	patchDylib = patchTarget: dylibPath: ''patchForDylib "${dylibPath}" "${patchTarget}"'';

	patchCmd.linux = lib.dedent ''
		patchelf --add-needed "$1" "$2"
	'';

	patchCmd.darwin = lib.dedent ''
		install_name_tool -add_rpath "$1" "$2"
	'';

	bodyLines = lib.foldlAttrsToList' runtimeDependenciesFor' (patchTarget: dylibPaths:
		assert lib.isString patchTarget;
		assert lib.isList dylibPaths;
		lib.forEach dylibPaths (patchDylib patchTarget)
	);

in makeSetupHook {
	name = hookName;

	substitutions = {
		body = lib.concatStringsSep "\n" bodyLines;
		patchCmdBody = patchCmd.${hostPlatform.parsed.kernel.name};

		inherit hookName;
	};
} ./absolute-dylibs.sh)
