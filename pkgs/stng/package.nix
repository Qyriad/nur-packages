{
	lib,
	stdenv,
	fetchFromCodeberg,
	rustPlatform,
	rustHooks,
	cargo,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
}: stdenv.mkDerivation (final: let
	self = final.finalPackage;
in {
	pname = "stng";
	version = "1.2.0";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromCodeberg {
		owner = "atomdrift";
		repo = "stng";
		tag = "v${self.version}";
		hash = "sha256-wxchyduplUcXINqhPmbTpIfPZyuYDsbqPJO4mU0AEcw=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-WXWVsmgevsAoi+J75iOdPx7Z02BlztbQV1kAxxSfXmI=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];
}))
