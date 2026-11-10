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
	pname = "git-forge";
	version = "0.11.0";

	src = fetchFromGitHub {
		owner = "git-pkgs";
		repo = "forge";
		tag = "v${self.version}";
		hash = "sha256-CrUwxTcDyMOcimIh5xya70F3pNe5qRkykQ/lSjW5tes=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-yhoG6qRZ5v+lHzArb3GKjK95ZT/hqCYI1xrgs6hNf48=";
	};

	nativeBuildInputs = goHooks.asList;

	meta = {
		homepage = "https://github.com/git-pkgs/forge";
		description = "CLI for working with git forges. Supports GitHub, GitLab, Gitea/Forgejo, and Bitbucket Cloud through a single interface.";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder goHooks.go.version "1.26.0";
		mainProgram = "forge";
	};
})
