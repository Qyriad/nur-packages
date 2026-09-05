{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "hexapoda";
	version = "1.0.0";

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "simonomi";
		repo = "hexapoda";
		tag = "v${self.version}";
		hash = "sha256-UL9y7ofI9VRGbmKG2tX2Ax/So1OhemznUFPR9LOA6Os=";
	};

	cargoDeps = fetchCargoVendor {
		inherit (self) src;
		name = lib.suffixName self "cargo-deps";
		hash = "sha256-pfzziyjlrMFM65+ZusqXpp+utVHHV0pWE2lCZwHYiBM=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	passthru.fromHead = lib.mkHeadFetch {
		inherit self;
		extraAttrs = self: {
			cargoDeps = importCargoLock {
				lockFile = self.src + "/Cargo.lock";
				allowBuiltinFetchGit = true;
			};
		};
	};

	meta = {
		homepage = "https://github.com/simonomi/hexapoda";
		description = "A colorful modal hex editor";
		license = with lib.licenses; [ gpl3Only ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder cargo.version "1.88.0";
		mainProgram = "hexapoda";
	};
}))
