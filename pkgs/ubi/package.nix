{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	libiconv,
	cacert,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: let
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
		optionalDarwin
	;
in stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "ubi";
	version = "0.12.0";

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "houseabsolute";
		repo = "ubi";
		tag = "v${self.version}";
		hash = "sha256-rLrh+8onizKeM3azqO20X0QH0lFy2F3zPhFqQ+FpM3Y=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.pname}-cargo-deps-${self.version}";
		inherit (self) src;
		hash = "sha256-+jWn5mM2jD99wdwgIx3CEl88T9aZP9HdHAWPI/dehEY=";
	};

	versionCheckProgramArg = "--version";

	# The integration tests seem to have to preconditions.
	cargoTestFlags = [ "--lib" ];
	__darwinAllowLocalNetworking = self.doCheck;
	__noChroot = stdenv.buildPlatform.isDarwin && self.doCheck;

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	buildInputs = optionalDarwin [
		libiconv
	];

	nativeInstallCheckInputs = [
		versionCheckHook
		cacert
	];

	passthru = {
		fromHead = lib.mkHeadFetch {
			inherit self;
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
		broken = lib.versionOlder cargo.version "1.88";
		mainProgram = "ubi";
	};
}))
