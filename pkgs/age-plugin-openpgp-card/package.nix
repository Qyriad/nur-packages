{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustPlatform,
	rustHooks,
	cargo,
	pkg-config,
	pcsclite,
}: lib.callWith [ rustPlatform ] ({
	fetchCargoVendor,
	cargoSetupHook,
	cargoBuildHook,
	cargoCheckHook,
	cargoInstallHook,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "age-plugin-openpgp-card";
	version = "0.1.3";

	src = fetchFromGitHub {
		owner = "wiktor-k";
		repo = "age-plugin-openpgp-card";
		tag = "v${self.version}";
		hash = "sha256-JTZs4kJCi3O3QIlqFz7VPbAlqDqRhfs2b/fHKMd5zKg=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
		pkg-config
	];

	buildInputs = [
		pcsclite
	];

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-pOcjSB+N9u72sfZaAoTNsKQC0lCCX0TWhwN6dLGJ2wk=";
	};

	meta = {
		homepage = "https://github.com/wiktor-k/age-plugin-openpgp-card";
		description = "Age plugin for using ed255519 on OpenPGP Card devices (Yubikeys, Nitrokeys)";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit asl20 ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder cargo.version lib.commonVersions.rust.edition2024;
		mainProgram = "age-plugin-openpgp-card";
	};
}))
