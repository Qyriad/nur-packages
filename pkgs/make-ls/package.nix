{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	fetchGoModules,
	goHooks,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "make-ls";
	version = "0.1.25";

	src = fetchFromGitHub {
		owner = "owenrumney";
		repo = "make-ls";
		tag = "v${self.version}";
		hash = "sha256-0E/aUbhlRliAL8aLOINuWm7YyzVtTpzq5jJiVEGk38Y=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-HJYqbYDN7HslR4Zar2JnO/xbwgKFffH8tMrUAHYnzFU=";
	};

	nativeBuildInputs = goHooks.asList ++ [
	];

	meta = {
		homepage = "https://github.com/owenrumney/make-ls";
		description = "Language Server for Makefiles";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder goHooks.go.version "1.25.0";
		mainProgram = "make-ls";
	};
})

