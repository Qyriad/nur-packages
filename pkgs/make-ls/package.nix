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
	version = "0.1.16";

	src = fetchFromGitHub {
		owner = "owenrumney";
		repo = "make-ls";
		tag = "v${self.version}";
		hash = "sha256-pgLK84+eriAPDeteWQUXXvN9zM3d8dn/J6zWdrPOtVc=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-7QwDZZ8MKL210z/Bs8DKkRhj/Ju63yYQFlqQ2zJI5OE=";
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

