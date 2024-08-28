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

  runtimeDependenciesFor' = lib.flip lib.mapAttrs runtimeDependenciesFor (name: value:
    assert lib.isList value;
    lib.forEach value (item: assert lib.isString item; item)
  );

  patchDylib = patchTarget: dylibPath: lib.trim ''
    patchelf --add-needed "${dylibPath}" "${patchTarget}"
  '';

  lines = lib.foldlAttrsToList' runtimeDependenciesFor' (patchTarget: dylibPaths:
    assert lib.isString patchTarget;
    assert lib.isList dylibPaths;
    lib.forEach dylibPaths (patchDylib patchTarget)
  );

in makeSetupHook {
  name = "absolute-dylibs-hook-${name}";

  substitutions = {
    body = lib.concatStringsSep "\n" lines;
  };
} ./absolute-dylibs.sh)
