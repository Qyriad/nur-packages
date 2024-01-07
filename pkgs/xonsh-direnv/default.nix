{
  python3,
  fetchFromGitHub,
  direnv
}:

let
  inherit (python3.pkgs) buildPythonPackage setuptools;

  pname = "xonsh-direnv";
  version = "1.6.1";
in
  buildPythonPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "74th";
      repo = "xonsh-direnv";
      rev = version;
      sha256 = "sha256-979y+jUKZkdIyXx4q0f92jX/crFr9LDrA/5hfXm1CpU=";
      name = "${pname}-source";
    };

    nativeBuildInputs = [
      setuptools
    ];

    buildInputs = [
      direnv
    ];

  }
