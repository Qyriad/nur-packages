{
	lib,
	stdenv,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	libiconv,
	testers,
	git,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: let
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
		optionalDarwin
	;
in stdenv.mkDerivation (self: {
	pname = "serie";
	version = "0.5.7";

	strictDeps = true;
	__structuredAttrs = true;
	doCheck = true;

	src = fetchFromGitHub {
		owner = "lusingander";
		repo = "serie";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-JWpqF19rZIw4GyKAzoGYsuCEDJOLDRiHRFJBsguISZ0=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-0pJDz6R/3EJl7K+cuy9ftngvOig/DO52cyUgkdnWa10=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeCheckInputs = [
		git
	];

	buildInputs = optionalDarwin [
		libiconv
	];

	passthru = {
		tests.version = testers.testVersion { package = self.finalPackage; };
		fromHead = lib.mkHeadFetch {
			self = self.finalPackage;
			headRef = "master";
			extraAttrs = self: {
				cargoDeps = importCargoLock {
					lockFile = self.src + "/Cargo.lock";
					allowBuiltinFetchGit = true;
				};
			};
		};
	};

	meta = {
		homepage = "https://github.com/lusingander/serie";
		description = "A rich git commit graph in your terminal, like magic 📚";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# Technically it's rustc version we care about here but whatever.
		broken = lib.versionOlder cargo.version "1.87.0";
		mainProgram = "serie";
	};
}))
