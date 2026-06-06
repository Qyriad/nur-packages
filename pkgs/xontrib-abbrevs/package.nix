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
		prompt-toolkit
		setuptools-scm
		xonsh
	;

	pname = "xontrib-abbrevs";
	version = "0.1.1";
in
	buildPythonPackage {
		inherit pname version;

		src = fetchFromGitHub {
			name = "${pname}-source";
			owner = "xonsh";
			repo = "xontrib-abbrevs";
			rev = "refs/tags/v${version}";
			hash = "sha256-xJUSbYo/+RFFCHenDEybVNxpOrEqSkU3eAaI+TNTmQI=";
		};

		format = "pyproject";

		nativeBuildInputs = [
			setuptools
			wheel
			poetry-core
			setuptools-scm
		];

		nativeCheckInputs = [
			xonsh
			prompt-toolkit
		];

		meta = {
			description = "Xonsh extension for using direnv";
			homepage = "https://github.com/74th/xonsh-direnv";
			license = lib.licenses.mit;
		};

	}
