{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustPlatform,
	rustHooks,
	cargo,
	versionCheckHook,
}: stdlib.makePackage stdenv (self: {
	pname = "folderify";
	version = "4.1.3";

	doCheck = true;
	doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

	src = fetchFromGitHub {
		owner = "lgarron";
		repo = "folderify";
		tag = "v${self.version}";
		hash = "sha256-Gq6rXqvvnFmAzKxnoJ70x2zLA4h/P0hjMMldNMc6jtI=";
	};

	cargoDeps = rustPlatform.fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-XyNcWwqy4w+b/epvjx6Jt7IBoZgxfowLOWeC6pMvaVo=";
	};

	versionCheckProgramArg = "--version";

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	meta = {
		homepage = "https://github.com/lgarron/folderify";
		description = "Generate pixel-perfect macOS folder icons in the native style.";
		longDescription = "📁 Generate pixel-perfect macOS folder icons in the native style.";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = lib.platforms.darwin;
		# MSRV of dependency time@0.3.47.
		broken = lib.versionOlder cargo.version "1.88.0";
		mainProgram = "folderify";
	};
})
