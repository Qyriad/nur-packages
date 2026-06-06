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
	pname = "obs-cmd";
	version = "1.0.0";

	strictDeps = true;
	__structuredAttrs = true;
	doCheck = true;

	src = fetchFromGitHub {
		owner = "grigio";
		repo = "obs-cmd";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-8lCqUN5FacDARZylR+s74l/mSP3Jy0GT5u03/WrUALM=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-Fyyr2oMHsIb9/jiqnzb94H5eknoy/WmwU7sL1cOxuPQ=";
	};

	versionCheckProgramArg = "--version";

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	buildInputs = optionalDarwin [
		libiconv
	];

	nativeCheckInputs = [
		versionCheckHook
	];

	passthru.fromHead = lib.mkHeadFetch {
		self = self.finalPackage;
		headRef = "master";
		extraAttrs = self: {
			cargoDeps = importCargoLock {
				lockFile = self.src + "/Cargo.lock";
				allowBuiltinFetchGit = true;
			};
		};
	};

	meta = {
		homepage = "https://github.com/grigio/obs-cmd";
		description = "An OBS cli for obs-websocket v5 the current obs-studio implementation";
		longDescription = ''
			An OBS cli for obs-websocket v5 the current obs-studio implementation. It is useful on Wayland Linux or to control OBS via terminal
		'';
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# Per their MSRV.
		broken = lib.versionOlder cargo.version "1.88.0";
		mainProgram = "obs-cmd";
	};
}))
