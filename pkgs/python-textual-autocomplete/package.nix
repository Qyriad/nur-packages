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
  version = "4.0.4";

  strictDeps = true;
  __structuredAttrs = true;

  # Source isn't on Github???
  src = fetchPypi {
    pname = "textual_autocomplete";
    inherit (self) version;
    hash = "sha256-CWmYe5ClPB91dT3+OtLH6g2XS1g53CoAotMywAAFeHE=";
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
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}))

