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
	version = "0.1.26";

	src = fetchFromGitHub {
		owner = "owenrumney";
		repo = "make-ls";
		tag = "v${self.version}";
		hash = "sha256-C/6IRKdrOQQjrx//OWM51oid/LnuyW7/Njk0EPv3wHA=";
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
		broken = lib.versionOlder goHooks.go.version "1.26.10";
		mainProgram = "make-ls";
	};
})

