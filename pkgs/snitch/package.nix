{
	lib,
	stdenv,
	fetchFromGitHub,
	fetchGoModules,
	goHooks,
}: stdenv.mkDerivation (self: {
	pname = "snitch";
	version = "0.2.0";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "karol-broda";
		repo = "snitch";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-krZf6bx1CZGgwg7cu2f2dzPYFEU4rM/nZjGtkXgGQkM=";
	};

	goModules = fetchGoModules {
		inherit (self.finalPackage) name;
		inherit (self) src;
		hash = "sha256-fX3wOqeOgjH7AuWGxPQxJ+wbhp240CW8tiF4rVUUDzk=";
	};

	nativeBuildInputs = goHooks.asList;

	passthru.fromHead = lib.mkHeadFetch { self = self.finalPackage; };

	meta = {
		homepage = "https://github.com/karol-broda/snitch";
		description = "a prettier way to inspect network connections";
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		mainProgram = "snitch";
	};
})
