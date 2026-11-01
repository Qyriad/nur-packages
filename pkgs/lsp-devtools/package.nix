{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	python3Packages,
	pythonHooks,
	versionCheckHook,
}: lib.callWith' python3Packages ({
	python,
	hatchling,
	aiosqlite,
	platformdirs,
	pygls,
	stamina,
	textual,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "lsp-devtools";
	version = "0.4.0";

	outputs = [ "out" "dist" ];

	src = fetchFromGitHub {
		owner = "swyddfa";
		repo = "lsp-devtools";
		tag = "lsp-devtools-v${self.version}";
		hash = "sha256-4AelyHCHnbHKnGXPok95rEkGkSOvdKHLCKm3ES+fy5c=";
	};

	sourceRoot = "${self.src.name}/lib/lsp-devtools";

	nativeBuildInputs = (pythonHooks python).asList ++ [
		hatchling
	];

	propagatedBuildInputs = [
		aiosqlite
		platformdirs
		pygls
		stamina
		textual
	];

	postFixupHooks = [ "wrapPythonPrograms" ];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	meta = {
		homepage = "https://lsp-devtools.readthedocs.io/en/latest/";
		description = "Developer tooling for language servers";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder pygls.version "2.0";
		mainProgram = "lsp-devtools";
	};
}))
