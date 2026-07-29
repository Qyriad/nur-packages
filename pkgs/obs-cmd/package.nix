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
	pname = "obs-cmd";
	version = "1.0.1";
	doCheck = true;

	src = fetchFromGitHub {
		owner = "grigio";
		repo = "obs-cmd";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-yIS9P2ljyiT8tiJmieQXWQcSkKmP7p0/XErujQRxDCE=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-jEGgTyqGprvtDkoWc5qihdeN91/4is3i7JBeqlm9KDw=";
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
		inherit self;
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
