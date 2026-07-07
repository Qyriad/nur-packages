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
}: stdlib.makePackage stdenv (self: {
	pname = "git-igitt";
	version = "0.1.21";
	doCheck = true;

	src = fetchFromGitHub {
		owner = "mlange-42";
		repo = "git-igitt";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-5AVKBew+HShWFZwm4xRmRSL76N2c84Yi97jgcqsslxM=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.pname}-cargo-deps-${self.version}";
		inherit (self) src;
		hash = "sha256-Z+Y6h9QYszpXFmahU5qXNHvuC4uJ4wJiCd39wndxw5c=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	buildInputs = [
		zlib
	];

	passthru.fromHead = lib.mkHeadFetch {
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
