{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustPlatform,
	rustHooks,
	cargo,
	nix-update-script,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "otree";
	version = "0.7.1";

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "fioncat";
		repo = "otree";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-Kcdhppc1hdPCQ+Q0ogmGSS9skC+ql96WQgCgKMBKcss=";
	};

	cargoDeps = fetchCargoVendor {
		inherit (self) src;
		name = lib.suffixName self "cargo-deps";
		hash = "sha256-B72PRaCMF4jEvsoUJyGFRNnA0ok3UYZfIwU/MAiWMJo=";
	};

	versionCheckProgramArg = "--version";

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	meta = {
		homepage = "https://github.com/fioncat/otree";
		description = "Command line tool to view objects (JSON/YAML/TOML) in a TUI tree widget";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# MSRV of multiple dependencies.
		broken = lib.versionOlder cargo.version "1.95.0";
		mainProgram = "otree";
	};
}))
