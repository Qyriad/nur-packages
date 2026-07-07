{
	lib,
	stdenv,
	stdlib,
	srcOnly,
	fetchFromGitHub,
	fetchGoModules,
	go,
	goHooks,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "lazycut";
	version = "0.3.9";

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "ozemin";
		repo = "lazycut";
		tag = "v${self.version}";
		hash = "sha256-SWcxk8GiXX81UZwv//1lukvXLtgMiJ7u4Rx1z6CKQoY=";
	};

	goModules = fetchGoModules {
		name = lib.suffixName self "go-modules";
		inherit (self) src;
		hash = "sha256-KfVNSESu06xiFYb+r2Yv4rgDc/NZ1tuGC0IWUdQrywo=";
	};

	nativeBuildInputs = goHooks.asList;

	passthru.srcs = srcOnly self;

	meta = {
		homepage = "https://github.com/ozemin/lazycut";
		license = with lib.licenses; [ mit ];
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder go.version "1.27.0";
		mainProgram = "lazycut";
	};
})
