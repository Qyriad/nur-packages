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
	version = "2.0.5";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "jdx";
		repo = "usage";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-No/BDBW/NRnF81UOuAMrAs4cXEdzEAxnmkn67mReUcM=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-W/CuXzwacarxgVv12TMVfo7Fr9qKJ7aZIO8xf4SygNA=";
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
		mainProgram = "usage";
	};
}))
