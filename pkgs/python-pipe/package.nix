{
  lib,
  python3,
  fetchPypi,
}:

let
  inherit (python3.pkgs) buildPythonPackage setuptools wheel;

  pname = "pipe";
  version = "2.2";
in
  buildPythonPackage {
    inherit pname version;

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-aiUxmOO8VC/68KQiI3ZYa86Fg7J6ndvCz7qlVMBJIw0=";
    };

    format = "pyproject";

    nativeBuildInputs = [
        setuptools
        wheel
    ];

    meta = {
      description = "A Python library to use infix notiation in Python";
      homepage = "https://github.com/JulienPalard/Pipe";
      license = lib.licenses.mit;
    };

  }
