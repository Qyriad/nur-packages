{
	lib,
	stdenvNoCC,
	fetchFromGitHub,
	python3Packages,
	pythonHooks,
}: lib.callWith' python3Packages ({
	python,
	pytestCheckHook,
	setuptools,
	setuptools-scm,
	xonsh,
	prompt-toolkit,
}: let
	stdenv = stdenvNoCC;
in stdenv.mkDerivation (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "xontrib-abbrevs";
	version = "0.1.1";

	__structuredAttrs = true;
	strictDeps = true;

	doCheck = true;
	doInstallCheck = true;

	outputs = [ "out" "dist" ];

	src = fetchFromGitHub {
		owner = "xonsh";
		repo = "xontrib-abbrevs";
		tag = "v${self.version}";
		hash = "sha256-xJUSbYo/+RFFCHenDEybVNxpOrEqSkU3eAaI+TNTmQI=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		setuptools
		setuptools-scm
	];

	propagatedBuildInputs = [
		xonsh
		prompt-toolkit
	];

	nativeCheckInputs = [
		pytestCheckHook
	];

	meta = {
		description = "Xonsh extension for using direnv";
		homepage = "https://github.com/74th/xonsh-direnv";
		license = lib.licenses.mit;
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
	};
}))
