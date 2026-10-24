{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	fetchGoModules,
	goHooks,
	pkg-config,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "anthropic-cli";
	version = "2.3.0";

	src = fetchFromGitHub {
		owner = "anthropics";
		repo = "anthropic-cli";
		tag = "v${self.version}";
		hash = "sha256-jq4V1EJEXg6mPH7G1VO4KQGXNiW7kyF5iL7OQsPO0RU=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-qgzTIgEVyPkYlxAmXd4oGmtW0EcNTEjVBpxfrH1Ucqg=";
	};

	nativeBuildInputs = goHooks.asList ++ [
		pkg-config
	];

	meta = {
		homepage = "https://github.com/hmnd/anthropic-cli";
		description = "The CLI for the Claude API";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder goHooks.go.version "1.25.5";
		#platforms = lib.platforms.linux;
		mainProgram = "ant";
	};
})
