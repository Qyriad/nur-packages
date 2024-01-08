{
  lib,
  python3,
  fetchFromGitHub,
}:

let
  inherit (python3.pkgs)
    buildPythonPackage
    setuptools
    wheel
    poetry-core
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

    meta = {
      description = "Xonsh extension for using direnv";
      homepage = "https://github.com/74th/xonsh-direnv";
      license = lib.licenses.mit;
    };

  }