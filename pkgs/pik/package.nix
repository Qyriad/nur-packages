{
	lib,
	stdenv,
	darwin,
	apple-sdk,
	fetchFromGitHub,
	rustPlatform,
	rustHooks,
	cargo,
	versionCheckHook,
}: lib.callWith [ darwin rustPlatform ] ({
	libiconv,
	DarwinTools,
	fetchCargoVendor,
}: let
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
		optionalDarwin
	;
in stdenv.mkDerivation (self: {
	pname = "pik";
	version = "0.27.0";

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = true;

	__darwinAllowLocalNetworking = self.finalPackage.doCheck;

	src = fetchFromGitHub {
		owner = "jacek-kurlit";
		repo = "pik";
		rev = "refs/tags/${self.version}";
		hash = "sha256-qpIMm6ivt+v+Un+F03cCtUYMX2dxN/jVGKeCMA20294=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-ugoXWn2ybdF/HbKqqUQWfNLqtxMdANTn3qnooOYLDKI=";
	};

	versionCheckProgramArg = "--version";

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	] ++ optionalDarwin [
		DarwinTools
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	passthru = {
		fromHead = lib.mkHeadFetch { self = self.finalPackage; };
	};

	meta = {
		homepage = "https://github.com/jacek-kurlit/pik";
		description = "Process interactive kill";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# lol with doesn't shadow.
		# Rust 2024 edition was stablized in Rust 1.85.
		broken = lib.versionOlder cargo.version "1.85.0";
		mainProgram = "pik";
	};
}))

