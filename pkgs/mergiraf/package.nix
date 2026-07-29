{
	lib,
	stdenv,
	stdlib,
	fetchFromGitea,
	rustHooks,
	rustPlatform,
	cargo,
	libiconv,
	git,
	#jj,
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
	pname = "mergiraf";
	version = "0.18.0";

	src = fetchFromGitea {
		domain = "codeberg.org";
		owner = "mergiraf";
		repo = "mergiraf";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-PfGiPH7CU8z+Flj3X04XnRdWcv5K+hTZMfvHpM52Fic=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-1MDjaaH2PcvQz0DKSTADRB+8YEUWP1GN2edHk4EDVGA=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	checkFlags = [
		# FIXME: figure out why this fails in the sandbox
		"--skip=jj"
	];

	nativeCheckInputs = [
		git
		#jj
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
			extraAttrs = self: {
				cargoDeps = importCargoLock {
					lockFile = self.src + "/Cargo.lock";
					allowBuiltinFetchGit = true;
				};
			};
		};
	};

	meta = {
		homepage = "https://mergiraf.org";
		description = "A syntax-aware git merge driver for a growing collection of programming languages and file formats";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ gpl3Only ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# Rust 2024 edition was stablized in Rust 1.85.
		# `let` expressions were stablized in Rust 1.88.
		broken = lib.versionOlder cargo.version "1.88.0";
		mainProgram = "mergiraf";
	};
}))
