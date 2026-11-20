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
	pname = "avahi2dns";
	version = "0.2.1";

	src = fetchFromGitHub {
		owner = "LouisBrunner";
		repo = "avahi2dns";
		tag = "${self.version}";
		hash = "sha256-/FtgkDi7GRTQPBvtfT1CbTdrJ+VU2SRZbUILs/M5Dcw=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-s+NuVtHmN963kNyaIsA5q9a+e1uDvQsH4qNDF63gk0Y=";
	};

	nativeBuildInputs = goHooks.asList;

	installCheckPhase = lib.dedent ''
		runHook preInstallCheck
		"$out/bin/$NIX_MAIN_PROGRAM" --help
		runHook postInstallCheck
	'';

	meta = {
		homepage = "https://github.com/LouisBrunner/avahi2dns";
		description = "";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder goHooks.go.version "1.26.2";
		mainProgram = "avahi2dns";
	};
})
