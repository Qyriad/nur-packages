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
	version = "0.10.0";

	src = fetchFromGitHub {
		owner = "git-pkgs";
		repo = "forge";
		tag = "v${self.version}";
		hash = "sha256-L0n8fROMUUtTSWIgiPzSJKKO9MhfQKh8NtFbhJTZZNw=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-5LY38XYsNXaR9tMeP4Y3CvN7MWbRgoeg1tpIQEVGmzk=";
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
