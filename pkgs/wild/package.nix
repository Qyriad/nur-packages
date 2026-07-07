{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustPlatform,
	rustHooks,
	cargo,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
}: stdlib.makePackage stdenv (self: {
	pname = "wild";
	version = "0.9.0";

	src = fetchFromGitHub {
		owner = "davidlattimore";
		repo = "wild";
		rev = "refs/tags/${self.version}";
		hash = "sha256-v4lPgZDPvRTAekkU9Vku9llgpOsaVtKt91VFUGrEeKw=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-ADJLtTRXcVWcbvgwXvCs0wxcGp2XP1LZJUJ4hpuzVHQ=";
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
		# Wild's MSRV is 1.94.
		broken = lib.versionOlder cargo.version "1.94";
		mainProgram = "wild";
	};
}))
