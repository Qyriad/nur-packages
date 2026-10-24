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
}: let
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform) optionalDarwin;
in stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "usage";
	version = "7.1.2";

	# Some of the tests rely on `usage` in PATH. We'll fix those later.
	dontCargoCheck = true;

	src = fetchFromGitHub {
		owner = "jdx";
		repo = "usage";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-A7x5lm4bNqpfsVQO5ie7XbtSuIAqeYA3e2gtLOUncxQ=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-M3TJt3aHIPuHUn1jPczhPLgVLjzruxzT0BebVLV0UTA=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	buildInputs = optionalDarwin [
		libiconv
	];

	meta = {
		homepage = "https://github.com/jdx/usage";
		description = "A tool for CLI specifications";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = lib.platforms.all;
		# MRSV of dependency "kdl@6.7.0".
		broken = lib.versionOlder cargo.version "1.95.0";
		mainProgram = "usage";
	};
}))
