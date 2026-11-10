{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	zlib,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "git-igitt";
	version = "0.2.1";
	doCheck = true;

	src = fetchFromGitHub {
		owner = "mlange-42";
		repo = "git-igitt";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-3heVYUe9bAApkZVMM0uAj54X6Hx0lvs7sx4bIJ0elJw=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.pname}-cargo-deps-${self.version}";
		inherit (self) src;
		hash = "sha256-0LH7CVeXxyRXcyCS5NZ0b5Gst5AHsF/4wF7hcOppNxI=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	buildInputs = [
		zlib
	];

	passthru.fromHead = lib.mkHeadFetch {
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

	meta = {
		homepage = "https://github.com/mlange-42/git-igitt";
		description = "Interactive, cross-platform Git terminal application with clear git graphs arranged for your branching model";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# Dependency "time@0.3.47" MRSV.
		broken = lib.versionOlder cargo.version "1.88.0";
		mainProgram = "git-igitt";
	};
}))
