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
	version = "0.30.1";

	strictDeps = true;
	__structuredAttrs = true;
	doCheck = true;

	src = fetchFromGitHub {
		owner = "grigio";
		repo = "obs-cmd";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-LBnizJnUqTCfAAmVR9piQeQGKvgAvylLwWZ6ARa3HAw=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-Mb8IS9ahbKIYzlyAWiAFQCjOWRdrFXS/vyEl54OOlYw=";
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
