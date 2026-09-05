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
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "wild";
	version = "0.10.0";

	doCheck = false;

	src = fetchFromGitHub {
		owner = "davidlattimore";
		repo = "wild";
		rev = "refs/tags/${self.version}";
		hash = "sha256-jIkeR68C41jn0A3DjEpbrEYCwuqIS3n0bRed2K6c5iY=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-GWS94lacSiUjE733wlBKVpHHbbimYIV411a812ryL3U=";
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
