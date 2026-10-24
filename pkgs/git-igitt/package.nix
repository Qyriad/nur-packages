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
	version = "0.2.0";
	doCheck = true;

	src = fetchFromGitHub {
		owner = "mlange-42";
		repo = "git-igitt";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-ge4QheY9dEqU4ndYJcO11TPvVwSuL7/RK6WIakHrV7c=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.pname}-cargo-deps-${self.version}";
		inherit (self) src;
		hash = "sha256-XopYsa//QKeXh9yQbqLnbhxj//Umbt5Rm4XSHkAlBuc=";
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
