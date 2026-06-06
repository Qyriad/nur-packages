{
	lib,
	stdenv,
	fetchFromGitea,
	rustPlatform,
	rustHooks,
	cargo,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
}: stdenv.mkDerivation (final: let
	self = final.finalPackage;
in {
	pname = "stng";
	version = "1.5.1";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitea {
		domain = "codeberg.org";
		owner = "atomdrift";
		repo = "stng";
		tag = "v${self.version}";
		hash = "sha256-YOvvYeiR8VMTJ68g4PjQgph28KZJ7N/zknZRpC5iZiE=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-P/5p/+PVbQ9BoWKkBULI1fkD6FqZg6OQCZOaAy6p3Ow=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	meta = {
		homepage = "https://codeberg.org/atomdrift/stng";
		description = "strings(1) for malware analysts - stronger, better, faster";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ asl20 ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# `unsigned_is_multiple_of` was stablized in 1.87.0.
		# https://github.com/rust-lang/rust/issues/128101
		broken = lib.versionOlder cargo.version "1.87.0";
		mainProgram = "stng";
	};
}))
