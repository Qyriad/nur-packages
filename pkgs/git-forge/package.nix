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
	version = "0.6.0";

	src = fetchFromGitHub {
		owner = "git-pkgs";
		repo = "forge";
		tag = "v${self.version}";
		hash = "sha256-kVKDHcrtXbOqqZoiKb/SxOKbTy2A7oHomlUImkcnxmA=";
	};

	goModules = fetchGoModules {
		inherit (self) name src;
		hash = "sha256-sduEepxhOCLk7/YMJbIwtt78Bo9UJ5olb8po7drxPZw=";
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
