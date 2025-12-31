{
	lib,
	stdenv,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	zlib,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: stdenv.mkDerivation (self: {
	pname = "git-igitt";
	version = "0.1.19";

	strictDeps = true;
	__structuredAttrs = true;
	doCheck = true;

	src = fetchFromGitHub {
		owner = "mlange-42";
		repo = "git-igitt";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-kryC07G/sMMtz1v6EZPYdCunl/CjC4H+jAV3Y91X9Cg=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.pname}-cargo-deps-${self.version}";
		inherit (self) src;
		hash = "sha256-45ME5Uaqa6qKuqvO1ETEVrySiAylPmx30uShQPPGNmY=";
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
		broken = lib.versionOlder cargo.version "1.83.0";
		mainProgram = "git-igitt";
	};
}))
