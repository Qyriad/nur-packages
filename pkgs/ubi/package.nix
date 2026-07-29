{
	lib,
	stdenv,
	stdlib,
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
in stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "ubi";
	version = "0.9.0";

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "houseabsolute";
		repo = "ubi";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-3+cC1X/Ao7x30UCmwUCz/E6HXaIk2G5EDKhgGUKexaE=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.pname}-cargo-deps-${self.version}";
		inherit (self) src;
		hash = "sha256-qTzJ3s9tsv30gN3Rz8DJqHhRnQW5svTkWBDkR1ZOlIo=";
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
		broken = lib.versionOlder cargo.version "1.85";
		mainProgram = "ubi";
	};
}))
