{
	lib,
	stdenv,
	stdlib,
	fetchFromGitea,
	rustPlatform,
	rustHooks,
	cargo,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
}: stdlib.makePackage stdenv (final: let
	self = final.finalPackage;
in {
	pname = "stng";
	version = "1.7.0";

	src = fetchFromGitea {
		domain = "codeberg.org";
		owner = "atomdrift";
		repo = "stng";
		tag = "v${self.version}";
		hash = "sha256-cIQV1pJ97XX4bhotVfDvFSABG6sU3/nL4o1S3cpKI7s=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-0msK2XFFCNohe0sbrwZM7bl2DAnPcTO3n75l5Nobfbc=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	# Requires networking.
	checkFlags = [
		"--skip=sockaddr_extraction_tests::test_kimwolf_installer_ip_extraction"
		# No idea tbh.
		"--skip=test_goodboy_loader_detection"
		"--skip=test_flush_cache_real_file"
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
