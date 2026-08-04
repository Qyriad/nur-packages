{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "usbtree";
	version = "0.1.1";

	src = fetchFromGitHub {
		owner = "gnomeria";
		repo = "usbtree";
		tag = "v${self.version}";
		hash = "sha256-780SdrC2vaLQKJElabevYifBSv1WUOwjqYfbj7Fsm3E=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-vendor";
		inherit (self) src;
		hash = "sha256-6uP2YuPeZVZa+AKOyki+hgvE28+yWkPvpt+QifFOxgo=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	meta = {
		homepage = "https://gnomeria.github.io/usbtree/";
		description = "Live USB tree in your terminal";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# MSRV of multiple dependencies.
		broken = lib.versionOlder cargo.version "1.88.0";
		mainProgram = "usbtree";
	};
}))
