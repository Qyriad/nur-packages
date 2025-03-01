{
  lib,
  stdenvNoCC,
  fetchPypi,
  python3,
  python3Packages,
}: lib.callWith' python3Packages ({
  pypaBuildHook,
  pypaInstallHook,
  pythonOutputDistHook,
  pythonNamespacesHook,
  pythonImportsCheckHook,
  poetry-core,
  hatchling,
}: let
  stdenv = stdenvNoCC;
in stdenv.mkDerivation (self: {
  pname = "${python3.pythonAttr}-textual-autocomplete";
  version = "3.0.0a13";

  strictDeps = true;
  __structuredAttrs = true;

  # Source isn't on Github???
  src = fetchPypi {
    pname = "textual_autocomplete";
    inherit (self) version;
    hash = "sha256-21pK6VbdfW3s5T9/aV6X8qt1gZ3Za4ocBk7Flms6sRM=";
  };

  outputs = [ "out" "dist" ];

  outputChecks = let
    disallowedReferences = lib.optionals (python3.stdenv.hostPlatform != python3.stdenv.buildPlatform) [
      python3.pythonOnBuildForHost
    ];
  in {
    out = disallowedReferences;
    dist = disallowedReferences;
  };

  nativeBuildInputs = [
    pypaBuildHook
    pypaInstallHook
    pythonOutputDistHook
    pythonNamespacesHook
    pythonImportsCheckHook
    poetry-core
    hatchling
  ];

  meta = {
    homepage = "https://github.com/darrenburns/textual-autocomplete";
    description = "Python library for creating dropdown autocompletion menus in Textual applications";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
  };
}))

