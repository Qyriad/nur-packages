{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  python3Packages,
  uv,
  python-textual_1_0,
  python-textual-autocomplete,
}: lib.callWith' python3Packages ({
  pypaBuildHook,
  pypaInstallHook,
  pythonOutputDistHook,
  pythonNamespacesHook,
  pythonImportsCheckHook,
  wrapPython,
  setuptools,
  hatchling,
  click,
  xdg-base-dirs,
  click-default-group,
  httpx,
  brotli,
  pyperclip,
  pydantic,
  pyyaml,
  pydantic-settings,
  python-dotenv,
  watchfiles,
  rich,
  platformdirs,
}: let
  stdenv = stdenvNoCC;
in stdenv.mkDerivation (self: {
  pname = "posting";
  version = "2.3.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "darrenburns";
    repo = "posting";
    rev = "refs/tags/${self.version}";
    hash = "sha256-lL85gJxFw8/e8Js+UCE9VxBMcmWRUkHh8Cq5wTC93KA=";
  };

  env = {
    LANG = (if python3.stdenv.hostPlatform.isDarwin then "en_US" else "C") + ".UTF-8";
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
    python3
    uv
    pypaBuildHook
    pypaInstallHook
    pythonOutputDistHook
    pythonNamespacesHook
    pythonImportsCheckHook
    wrapPython
    setuptools
    hatchling
  ];

  propagatedBuildInputs = [
    click
    xdg-base-dirs
    click-default-group
    httpx
    brotli
    pyperclip
    pydantic
    pyyaml
    pydantic-settings
    python-dotenv
    python-textual_1_0
    python-textual-autocomplete
    watchfiles

    # Not in the pyproject.toml, but required anyway.
    rich
    platformdirs
  ];

  postFixup = ''
    wrapPythonPrograms
  '';

  meta = {
    homepage = "https://github.com/darrenburns/posting";
    mainProgram = "posting";
  };
}))
