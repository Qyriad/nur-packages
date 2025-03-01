{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  python3Packages,
}: lib.callWith' python3Packages ({
  pypaBuildHook,
  pypaInstallHook,
  pythonOutputDistHook,
  pythonNamespacesHook,
  pythonImportsCheckHook,
  poetry-core,
}: let
  stdenv = stdenvNoCC;
in stdenv.mkDerivation (self: {
  pname = "${python3.pythonAttr}-textual";
  version = "1.0.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Textualize";
    repo = "textual";
    rev = lib.gitTagV self;
    hash = "sha256-3pNUDkkq9X3W9DdWp4M4h4ddHN+GzUxLCFNJJdAtRJM=";
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
  ];

  meta = {
    homepage = "https://github.com/Textualize/textual";
  };
}))
