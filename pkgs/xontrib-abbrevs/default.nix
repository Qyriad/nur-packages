{
  lib,
  python3,
  xonsh-unwrapped,
  fetchFromGitHub,
}:

let
  inherit (python3.pkgs)
    buildPythonPackage
    setuptools
    wheel
    poetry-core
    prompt-toolkit
  ;

  pname = "xontrib-abbrevs";
  version = "0.0.1";
in
  buildPythonPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "xonsh";
      repo = "xontrib-abbrevs";
      rev = version;
      sha256 = "sha256-DrZRIU5mzu8RUzm0jak/Eo12wbvWYusJpmqgIAVwe00=";
      name = "${pname}-source";
    };

    format = "pyproject";

    nativeBuildInputs = [
      setuptools
      wheel
      poetry-core
    ];

    nativeCheckInputs = [
      xonsh-unwrapped
      prompt-toolkit
    ];

    meta = {
      description = "Xonsh extension for using direnv";
      homepage = "https://github.com/74th/xonsh-direnv";
      license = lib.licenses.mit;
    };

  }
