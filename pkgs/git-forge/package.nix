{
	lib,
	stdenv,
	fetchFromGitHub,
	fetchGoModules,
	goHooks,
}: stdenv.mkDerivation (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "git-forge";
	version = "0.5.1";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "git-pkgs";
		repo = "forge";
		tag = "v${self.version}";
		hash = "sha256-oLkaqnyCV8dOs33bz1FqhQT7A/smupk2Y5kaAuD1F3M=";
	};

	goModules = fetchGoModules {
		inherit (self) name src;
		hash = "sha256-HqO2GsPkpACAlNSm6VGoyAWKzWgkADmDrevLHIHNTaI=";
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
