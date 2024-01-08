{
  lib,
  python3,
  fetchPypi,
}:

let
  inherit (python3.pkgs) buildPythonPackage setuptools wheel;

  pname = "pipe";
  version = "2.0";
in
  buildPythonPackage {
    inherit pname version;

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-oc8/KfmFdrfmVSIxFCvHEejdMkUTosRSX8aMM/R/q60=";
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
