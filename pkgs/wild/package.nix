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
	version = "0.7.0";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "davidlattimore";
		repo = "wild";
		rev = "refs/tags/${self.version}";
		hash = "sha256-x0IZuWjj0LRMj4pu2FVaD8SENm/UVtE1e4rl0EOZZZM=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-5s0qS8y0+EH+R1tgN2W5/+t+GdjbQdRVLlcA2KjpHsE=";
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
