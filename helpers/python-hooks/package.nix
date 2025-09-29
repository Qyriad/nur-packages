{
  lib,
  newScope,
  stdenvNoCC,
  ensureNewerSourcesForZipFilesHook,
}: let
  inherit (stdenvNoCC)
    hostPlatform
    buildPlatform
  ;
in python: lib.recurseIntoAttrs (lib.makeScope newScope (self: {
  inherit python;
  inherit (python.pkgs)
    pypaBuildHook
    pypaInstallHook
    pythonRuntimeDepsCheckHook
    pythonOutputDistHook
    pythonRemoveBinBytecodeHook
    wrapPython
    setuptools
    pythonCatchConflictsHook
    pythonNamespacesHook
    pythonImportsCheckHook
  ;
  inherit
    ensureNewerSourcesForZipFilesHook
  ;


  asList = [
    self.pypaBuildHook
    self.pypaInstallHook
    self.pythonRuntimeDepsCheckHook
    self.pythonOutputDistHook
    self.ensureNewerSourcesForZipFilesHook
    self.pythonRemoveBinBytecodeHook
    self.wrapPython
    self.setuptools
    self.pythonImportsCheckHook
  ] ++ lib.optionals (buildPlatform.canExecute hostPlatform) [
    self.pythonCatchConflictsHook
  ] ++ lib.optionals (self.python.pythonAtLeast "3.3") [
    self.pythonNamespacesHook
  ];
}))
