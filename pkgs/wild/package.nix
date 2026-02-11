{
	lib,
	stdenv,
	fetchFromGitHub,
	rustPlatform,
	rustHooks,
	cargo,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
}: stdenv.mkDerivation (self: {
	pname = "wild";
	version = "0.8.0";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "davidlattimore";
		repo = "wild";
		rev = "refs/tags/${self.version}";
		hash = "sha256-E5cmZuOtF+MNTPyalKjnguhin70zqtDDB0D71ZpeE48=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-r0r7sN1SW5TIybHORfzJkN51Y0REEC2/h7q71GxUgAM=";
	};

	versionCheckProgramArg = "--version";

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	meta = {
		homepage = "https://github.com/davidlattimore/wild";
		description = "A linker with the goal of being very fast for iterative development";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit asl20 ];
		platforms = lib.platforms.linux;
    # Wild's MSRV is 1.89.
		broken = lib.versionOlder cargo.version "1.89";
		mainProgram = "wild";
	};
}))
