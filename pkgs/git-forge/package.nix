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
	version = "0.10.1";

	src = fetchFromGitHub {
		owner = "git-pkgs";
		repo = "forge";
		tag = "v${self.version}";
		hash = "sha256-h4sJdNMopRjE8WmNrcClYxUUlchy2ZgRYsKLNAKDhZM=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-/wGFcszJHNzXlAtUAw7aSDneOhlW9pt4yjH/7P0Syp4=";
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
