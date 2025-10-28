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
	version = "1.5.1";
in
	buildPythonApplication {
		inherit pname version;

		__structuredAttrs = true;
		strictDeps = true;

		src = fetchFromGitHub {
			owner = "mgedmin";
			repo = "strace-process-tree";
			rev = version;
			sha256 = "sha256-YGDC5f11feCO75u7AZftMVfYVXoqg0QFhGoVq0mOURM=";
			name = "${pname}-source";
		};

		format = "pyproject";

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
