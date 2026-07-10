{
	lib,
	stdenvNoCC,
	stdlib,
	fetchFromGitHub,
	pythonHooks,
	python3Packages,
	poetry,
}: lib.callWith' python3Packages ({
	python,
	pytestCheckHook,
	pythonRelaxDepsHook,
	click,
	pyyaml,
	poetry-core,
}: let
	stdenv = stdenvNoCC;
in stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "macos-compose";
	version = "1.2.0";

	outputs = [ "out" "dist" ];

	src = fetchFromGitHub {
		owner = "Granitosaurus";
		repo = "macos-compose";
		tag = "${self.version}";
		hash = "sha256-1xT3/Tj09DyDIIbhOsx/wfSKS4sGWrfjBG7U5kDgbfM=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		pythonRelaxDepsHook
		poetry
		poetry-core
	];

	pypaBuildFlags = [
		# It's trying to find poetry-core==2.4.0 but we have 2.4.1.
		"--skip-dependency-check"
	];

	propagatedBuildInputs = [
		click
		pyyaml
	];

	pythonRelaxDeps = [ "click" "pyyaml" ];

	postFixup = "wrapPythonPrograms";

	nativeInstallCheckInputs = [
		pytestCheckHook
	];

	# We can't use versionCheckHook because macos-compose doesn't actually outputs its version.
	postInstallCheckHooks = [
		"$out/bin/gen-compose --help"
	];

	meta = {
		description = "Compose key for macOS";
		homepage = "https://github.com/Granitosaurus/macos-compose";
		license = with lib.licenses; [ gpl3Plus ];
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = lib.platforms.darwin;
		mainProgram = "gen-compose";
	};
}))
