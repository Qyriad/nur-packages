{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  inherit (python3.pkgs)
    buildPythonApplication
    setuptools
    wheel
    pytest
  ;

  pname = "strace-process-tree";
  version = "1.5.0";
in
  buildPythonApplication {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "mgedmin";
      repo = "strace-process-tree";
      rev = version;
      sha256 = "sha256-KxDI8sDTIsvMlHiFTEA8BcI1Pfkskoyn2wYCLd9fdE8=";
      name = "${pname}-source";
    };

    nativeBuildInputs = [
      setuptools
      wheel
    ];

    nativeCheckInputs = [
      pytest
    ];

    meta = {
      mainProgram = "strace-process-tree";
      description = "Tool to help me make sense of `strace -f` output";
      homepage = "https://github.com/mgedmin/strace-process-tree";
      license = lib.licenses.gpl2;
    };
  }
