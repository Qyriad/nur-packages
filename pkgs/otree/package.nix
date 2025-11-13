{
	lib,
	stdenv,
	fetchFromGitHub,
	rustPlatform,
	rustHooks,
	cargo,
	nix-update-script,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
}: stdenv.mkDerivation (self: {
	pname = "otree";
	version = "0.6.2";

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "fioncat";
		repo = "otree";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-A4UY3SRahpxl6xqJuamXlBenemJuvFS6KcHKOXEHDyw=";
	};

	cargoDeps = fetchCargoVendor {
		inherit (self) src;
		name = "${self.finalPackage.name}-cargo-deps";
		hash = "sha256-cePX4Uxu7BOsB1JIGAsDfiOLeVAgL+0Lnst4shtpEX4=";
	};

	versionCheckProgramArg = "--version";

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	passthru = {
		updateScript = nix-update-script { };
		fromHead = lib.mkHeadFetch { self = self.finalPackage; };
	};

	meta = {
		homepage = "https://github.com/fioncat/otree";
		description = "Command line tool to view objects (JSON/YAML/TOML) in a TUI tree widget";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		mainProgram = "otree";
	};
}))
