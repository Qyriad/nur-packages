{
	lib,
	stdenv,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	libiconv,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: let
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
		optionalDarwin
	;
in stdenv.mkDerivation (self: {
	pname = "ubi";
	version = "0.8.0";

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "houseabsolute";
		repo = "ubi";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-OK0+u+5vb5AkbSK6l8GJy0R4ylIbzWR/DDZs5bKo2CU=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.pname}-cargo-deps-${self.version}";
		inherit (self) src;
		hash = "sha256-e8yrn5WfUl89+aQqG1392ibbbWp0lhyP9828Hew/Zh0=";
	};

	versionCheckProgramArg = "--version";

	# The integration tests seem to have to preconditions.
	cargoTestFlags = [ "--lib" ];
	__darwinAllowLocalNetworking = self.finalPackage.doCheck;
	__noChroot = stdenv.buildPlatform.isDarwin && self.finalPackage.doCheck;

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	buildInputs = optionalDarwin [
		libiconv
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	passthru = {
		fromHead = lib.mkHeadFetch {
			self = self.finalPackage;
			headRef = "master";
			extraAttrs = self: {
				# Use IFD to get the latest Cargo dependencies too.
				cargoDeps = importCargoLock {
					lockFile = self.src + "/Cargo.lock";
					allowBuiltinFetchGit = true;
				};
			};
		};
	};

	meta = {
		homepage = "https://github.com/houseabsolute/ubi";
		description = "Universal binary installer";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit asl20 ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder cargo.version "1.85";
		mainProgram = "ubi";
	};
}))
