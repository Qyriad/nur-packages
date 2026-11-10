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
	version = "0.1.2";

	src = fetchFromGitHub {
		owner = "gnomeria";
		repo = "usbtree";
		tag = "v${self.version}";
		hash = "sha256-jpOFKNauivxE+gs7geqgyoCYUS1/4MYkzs20BxeJAQQ=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-vendor";
		inherit (self) src;
		hash = "sha256-eo2+4PnXX9hi+BJVepXpme2INZDhRxDY5EV3wRIruGY=";
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
