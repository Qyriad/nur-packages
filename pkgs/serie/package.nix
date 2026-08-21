{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	libiconv,
	git,
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
	pname = "serie";
	version = "0.8.2";
	doCheck = true;

	src = fetchFromGitHub {
		owner = "lusingander";
		repo = "serie";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-FD4GIDaPnd44xgT+NsDuhRuL7CnPZFVX96ATWlUGrHo=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-NQxjqe1kzEIxr6G5Iac9DQVIG26lox77AumgKLtYQ48=";
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

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	passthru = {
		fromHead = lib.mkHeadFetch {
			inherit self;
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
