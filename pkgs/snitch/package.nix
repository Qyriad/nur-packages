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
	pname = "snitch";
	version = "0.2.2";

	src = fetchFromGitHub {
		owner = "karol-broda";
		repo = "snitch";
		tag = "v${self.version}";
		hash = "sha256-SssAiRUfUaDgAoVO2rDacru8e914Wl+4sA4JQ4Mv4eA=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-fX3wOqeOgjH7AuWGxPQxJ+wbhp240CW8tiF4rVUUDzk=";
	};

	nativeBuildInputs = goHooks.asList;

	meta = {
		homepage = "https://github.com/karol-broda/snitch";
		description = "a prettier way to inspect network connections";
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder goHooks.go.version "1.25.0";
		mainProgram = "snitch";
	};
})
