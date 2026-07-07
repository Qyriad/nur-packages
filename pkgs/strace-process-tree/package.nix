{
	lib,
	stdenvNoCC,
	stdlib,
	fetchFromGitHub,
	python3Packages,
	pythonHooks,
}: lib.callWith' python3Packages ({
	python,
	setuptools,
	pytest,
	pytestCheckHook,
	pythonImportsCheckHook,
}: let
	stdenv = stdenvNoCC;
in stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "strace-process-tree";
	version = "1.5.3";

	outputs = [ "out" "dist" ];

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "mgedmin";
		repo = "strace-process-tree";
		tag = "${self.version}";
		sha256 = "sha256-yya8mL7aRl0KvkhyIRpah8DPLbQ75JX1rutV0/tOVHU=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		setuptools
	];

	nativeCheckInputs = [
		pytestCheckHook
	];

	meta = {
		mainProgram = "strace-process-tree";
		description = "Tool to help me make sense of `strace -f` output";
		homepage = "https://github.com/mgedmin/strace-process-tree";
		license = lib.licenses.gpl2;
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
	};
}))
