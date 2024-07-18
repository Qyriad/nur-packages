{
  lib,
  python3,
  fetchFromGitHub,
  direnv,
}:

let
  inherit (python3.pkgs) buildPythonPackage setuptools;

  pname = "xonsh-direnv";
  version = "1.6.2";
in
  buildPythonPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "74th";
      repo = "xonsh-direnv";
      rev = version;
      sha256 = "sha256-bp1mK+YO9htEQcRSD5wJkAZtQKK2t3IOW7Kdc6b8Lb0=";
      name = "${pname}-source";
    };

    nativeBuildInputs = [
      setuptools
    ];

    buildInputs = [
      direnv
    ];

    meta = {
      description = "Xonsh extension for command abbreviations. This expands input words as you type";
      homepage = "https://github.com/xonsh/xontrib-abbrevs";
      license = lib.licenses.mit;
    };

  }
