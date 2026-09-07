{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	versionCheckHook,
	pythonHooks,
	python3Packages,
}: lib.callWith' python3Packages ({
	python,
	pythonRelaxDepsHook,
	setuptools-scm,
	dacite,
	giturlparse,
	mako,
	rich,
	ruamel-yaml,
	shellingham,
	typer,
	west,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "zmk-cli";
	version = "0.5.0";

	outputs = [ "out" "dist" ];

	src = fetchFromGitHub {
		owner = "zmkfirmware";
		repo = "zmk-cli";
		tag = "v${self.version}";
		hash = "sha256-GhECLAvs4qkUGeINDSF4oJtZnXHxljmVVERyoezt35w=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		setuptools-scm
		pythonRelaxDepsHook
	];

	# FIXME: ruamel-yaml is… not getting picked up by this hook, I guess?
	#pythonRelaxDeps = [ "giturlparse" "rich" "typer" "ruamel-yaml" ];
	pythonRelaxDeps = true;

	propagatedBuildInputs = [
		dacite
		giturlparse
		mako
		rich
		ruamel-yaml
		shellingham
		typer
		west
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];
	# Needed for older Nixpkgs, as the command name is not pname.
	versionCheckProgram = "${placeholder "out"}/bin/${self.meta.mainProgram}";

	postFixupHooks = [ "wrapPythonPrograms" ];

	meta = {
		homepage = "https://github.com/zmkfirmware/zmk-cli";
		description = "Command-line tool for ZMK Firmware";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		mainProgram = "zmk";
	};
}))
