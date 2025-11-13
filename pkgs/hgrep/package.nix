{
	lib,
	stdenv,
	fetchFromGitHub,
	darwin,
	rustPlatform,
	cargo,
}: lib.callWith [ darwin rustPlatform ] ({
	libiconv,
	fetchCargoVendor,
	cargoSetupHook,
	cargoBuildHook,
	cargoCheckHook,
	cargoInstallHook,
}: let
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
		optionalDarwin
	;
in stdenv.mkDerivation (self: {
	pname = "hgrep";
	version = "0.3.9";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "rhysd";
		repo = "hgrep";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-xBLpEs0PvYb7sIca9yb3vhi2Bsr1BFqB0jlD+bZT2EI=";
	};

	cargoBuildType = "release";
	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-TP+PClv7FX3kRBwJ0RAKbKoTKpi7hTZgw/Z/ktFKbwQ=";
	};

	nativeBuildInputs = [
		cargo
		cargoSetupHook
		cargoBuildHook
		cargoInstallHook
	];

	doCheck = true;
	cargoCheckType = "test";
	nativeCheckInputs = [
		cargoCheckHook
	];

	buildInputs = optionalDarwin [
		libiconv
	];

	meta = {
		homepage = "https://github.com/rhysd/hgrep";
		description = "Grep with human-friendly search results";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# Seems broken on current Nixpkgs for aarch64-apple-darwin?
		#platforms = lib.attrValues { inherit (lib.platforms) all; };
		# Rust 2024 edition was stablized in Rust 1.85.
		broken = lib.versionOlder cargo.version "1.85.0";
		mainProgram = "hgrep";
	};
}))
