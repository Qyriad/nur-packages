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
	version = "0.28.1";

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = true;

	__darwinAllowLocalNetworking = self.finalPackage.doCheck;

	src = fetchFromGitHub {
		owner = "jacek-kurlit";
		repo = "pik";
		rev = "refs/tags/${self.version}";
		hash = "sha256-pDfqqQcYrK78OylwOiKc/Orul03MjdZxEHhpr8obm84=";
	};

	cargoDeps = fetchCargoVendor {
		name = "${self.finalPackage.name}-cargo-deps";
		inherit (self) src;
		hash = "sha256-/2E5VZt2/xWtPy4Zpo8lVn4sXR4Gq6+NJkKpNM7hOVg=";
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
		# Dependency 'sysinfo@0.37.0' requires rustc 1.88.
		broken = lib.versionOlder cargo.version "1.88";
		mainProgram = "pik";
	};
}))

