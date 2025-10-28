{
	lib,
	stdenv,
	fetchFromGitHub,
	rustPlatform,
	rustHooks,
	cargo,
	versionCheckHook,
}: stdenv.mkDerivation (self: {
	pname = "folderify";
	version = "4.1.1";

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

	src = fetchFromGitHub {
		owner = "lgarron";
		repo = "folderify";
		tag = "v${self.version}";
		hash = "sha256-mC4Fc/gY6iqmgrghaXu6xAaITs+nrMBUdICoeq0Az6g=";
	};

	cargoDeps = rustPlatform.fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-W1H7F8LNJ8Z9Ir/eDianp2GSr68maziT/4GxkM/5HFc=";
	};

	versionCheckProgramArg = "--version";

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	meta = {
		homepage = "https://github.com/lgarron/folderify";
		description = "Generate pixel-perfect macOS folder icons in the native style.";
		longDescription = "📁 Generate pixel-perfect macOS folder icons in the native style.";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = lib.platforms.darwin;
		mainProgram = "folderify";
	};
})
