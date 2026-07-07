{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustPlatform,
	cargo,
	pkg-config,
	pcsclite,
}: lib.callWith [ rustPlatform ] ({
	fetchCargoVendor,
	cargoSetupHook,
	cargoBuildHook,
	cargoCheckHook,
	cargoInstallHook,
}: stdlib.makePackage stdenv (self: {
	pname = "age-plugin-openpgp-card";
	version = "0.1.2";

	src = fetchFromGitHub {
		owner = "wiktor-k";
		repo = "age-plugin-openpgp-card";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-z1Q1Sg6qcQwhNDI6dCMf4BejZn5K9VzqLCVvkisB//k=";
	};

	nativeBuildInputs = [
		cargo
		cargoSetupHook
		cargoBuildHook
		cargoCheckHook
		cargoInstallHook
		pkg-config
	];

	buildInputs = [
		pcsclite
	];

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-MrtCm41Q/Zs3FZCkdsNX30vFFuxIHNHHz4fbhMXuxD4=";
	};
	cargoBuildType = "release";

	passthru = {
		fromHead = lib.mkHeadFetch { self = self.finalPackage; };
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
