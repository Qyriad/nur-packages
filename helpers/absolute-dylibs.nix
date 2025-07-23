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

  runtimeDependenciesFor' = lib.flip lib.mapAttrs runtimeDependenciesFor (name: value:
    assert lib.isList value;
    lib.forEach value (item: assert lib.isString item; item)
  );

  patchDylib = patchTarget: dylibPath: if hostPlatform.isLinux then
    "patchelf --add-needed \"${dylibPath}\" \"${patchTarget}\""
  else if hostPlatform.isDarwin then
    "install_name_tool -add_rpath \"${dylibPath}\" \"${patchTarget}\""
  else
    throw "mkAbsoluteDylibsHook: unimplemented platform '${hostPlatform.system}'"
  ;

  bodyLines = lib.foldlAttrsToList' runtimeDependenciesFor' (patchTarget: dylibPaths:
    assert lib.isString patchTarget;
    assert lib.isList dylibPaths;
    lib.forEach dylibPaths (patchDylib patchTarget)
  );

in makeSetupHook {
  name = "absolute-dylibs-hook-${name}";

  substitutions = {
    body = lib.concatStringsSep "\n" bodyLines;
  };
} ./absolute-dylibs.sh)
