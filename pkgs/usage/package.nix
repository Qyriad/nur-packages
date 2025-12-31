{
	lib,
	stdenv,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	libiconv,
	testers,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
}: let
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform) optionalDarwin;
in stdenv.mkDerivation (self: {
	pname = "usage";
	version = "2.11.0";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "jdx";
		repo = "usage";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-AFfI843y1fKdw2f4alz7WoeMQR2IPWDJ3SofCCMJVpQ=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-WC/q9yd1XJT/EtC9ES5fw6j45gyRo3k2eNEDwGmvDWo=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	buildInputs = optionalDarwin [
		libiconv
	];

	passthru = {
		fromHead = lib.mkHeadFetch { self = self.finalPackage; };
		tests.version = testers.testVersion { package = self.finalPackage; };
	};

	meta = {
		homepage = "https://github.com/jdx/usage";
		description = "A tool for CLI specifications";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = lib.platforms.all;
		broken = lib.versionOlder cargo.version "1.88.0";
		mainProgram = "usage";
	};
}))
