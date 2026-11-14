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
	version = "2.9.0";

	src = fetchFromGitHub {
		owner = "anthropics";
		repo = "anthropic-cli";
		tag = "v${self.version}";
		hash = "sha256-bjc2xaiyV5Lj+c8Oksmu3/Ij3J5+qj5Qak+yRlF4lJA=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-j5JWaXTl6eDWVfcyyctZsFOWMdawmnqOAsCBSqig/jI=";
	};

	# These don't build for us and don't seem necessary.
	excludedPackages = [ "sandboxes" ];

	nativeBuildInputs = goHooks.asList ++ [
		pkg-config
	];

	meta = {
		homepage = "https://github.com/hmnd/anthropic-cli";
		description = "The CLI for the Claude API";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder goHooks.go.version "1.26.10";
		#platforms = lib.platforms.linux;
		mainProgram = "ant";
	};
})
