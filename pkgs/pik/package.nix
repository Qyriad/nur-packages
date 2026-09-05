{
	lib,
	stdenv,
	stdlib,
	darwin,
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
in stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "pik";
	version = "1.0.1";

	doCheck = true;
	doInstallCheck = true;

	__darwinAllowLocalNetworking = self.doCheck;

	src = fetchFromGitHub {
		owner = "jacek-kurlit";
		repo = "pik";
		tag = "${self.version}";
		hash = "sha256-t9qrN6R+4jbwpIBXaUvGgnemZtSqDltly6Aspcd/sr8=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-SMoejcJW0Fk/j7+64VZSIwdBEwyK7plVesnOK2C6dio=";
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

	meta = {
		homepage = "https://github.com/jacek-kurlit/pik";
		description = "Process interactive kill";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# lol with doesn't shadow.
		# Dependency 'sysinfo@0.39.4' requires rustc 1.95
		broken = lib.versionOlder cargo.version "1.95.0";
		mainProgram = "pik";
	};
}))

