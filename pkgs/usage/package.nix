{
	lib,
	stdenv,
	stdlib,
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
in stdlib.makePackage stdenv (self: {
	pname = "usage";
	version = "3.4.0";

	src = fetchFromGitHub {
		owner = "jdx";
		repo = "usage";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-qavPQi3qIp47HYFY1ACW+RvCOMtWdVBGvjYtDgaammk=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-mzXdgcZNRvKbjHokTtxiaaN+xQLbbEMpHOMur3/zIjA=";
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
		# MRSV of dependency "kdl@6.7.0".
		broken = lib.versionOlder cargo.version "1.95.0";
		mainProgram = "usage";
	};
}))
