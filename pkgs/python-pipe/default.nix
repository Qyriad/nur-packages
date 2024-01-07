{
  fetchPypi,
  python3,
}:

let
  pname = "pipe";
  version = "2.0";

  inherit (python3.pkgs) buildPythonPackage setuptools wheel;
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

  } # buildPythonPackage
