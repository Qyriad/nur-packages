{
	lib,
	stdenvNoCC,
	python3Packages,
	pythonHooks,
	fetchPypi,
}: lib.callWith' python3Packages ({
	python,
	setuptools,
	pythonImportsCheckHook,
}: let
	stdenv = stdenvNoCC;
in stdenv.mkDerivation (self: {
	pname = "pipe";
	version = "2.2";

	__structuredAttrs = true;
	strictDeps = true;

	doCheck = true;
	doInstallCheck = true;

	outputs = [ "out" "dist" ];

	src = fetchPypi {
		inherit (self) pname version;
		sha256 = "sha256-aiUxmOO8VC/68KQiI3ZYa86Fg7J6ndvCz7qlVMBJIw0=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		setuptools
	];

	meta = {
		description = "A Python library to use infix notiation in Python";
		homepage = "https://github.com/JulienPalard/Pipe";
		license = lib.licenses.mit;
	};
}))
