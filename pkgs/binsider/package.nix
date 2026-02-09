{
	lib,
	stdenv,
	fetchFromGitHub,
	rustPlatform,
	libiconv,
	cargo,
	rustHooks,
	testers,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: let
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
		optionalDarwin
		;
in stdenv.mkDerivation (self: {
	pname = "binsider";
	version = "0.3.2";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "orhun";
		repo = "binsider";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-Un3pKb0+5rwK0tKRp+HVl3vynPt5V8YxhPiLgshL3L0=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-Lcnc2fVyzip+g/mZvbMarQHkjBTNhKB5kZVTHFsR+Xo=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	] ++ optionalDarwin [
		libiconv
	];

	passthru.tests = testers.testVersion { package = self.finalPackage; };
	passthru.fromHead = lib.mkHeadFetch {
		self = self.finalPackage;
		extraAttrs = self: {
			cargoDeps = importCargoLock {
				lockFile = self.src + "/Cargo.lock";
				allowBuiltinFetchGit = true;
			};
		};
	};

	meta = {
		homepage = "https://binsider.dev";
		description = "Analyze ELF binaries like a boss";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit asl20 ];
		platforms = lib.platforms.linux;
		broken = lib.versionOlder cargo.version "1.88.0";
		mainProgram = "binsider";
	};
}))
