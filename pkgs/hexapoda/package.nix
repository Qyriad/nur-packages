{
	lib,
	stdenv,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: stdenv.mkDerivation (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "hexapoda";
	version = "0.2.3";

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "simonomi";
		repo = "hexapoda";
		tag = "v${self.version}";
		hash = "sha256-ZIZVioyo/1U7sy6rWLcuABRsHO6rU69keQpfH6tfcD0=";
	};

	cargoDeps = fetchCargoVendor {
		inherit (self) src;
		name = lib.suffixName self "cargo-deps";
		hash = "sha256-4MeStfLWv/M3rycdTULuqAli7bUQXQ0WDZvYHWpOd1A=";
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
