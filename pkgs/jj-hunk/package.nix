{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	git,
	jujutsu,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "jj-hunk";
	version = "0.4.1";

	src = fetchFromGitHub {
		owner = "laulauland";
		repo = "jj-hunk";
		tag = "v${self.version}";
		hash = "sha256-lFuYTg6TW/Lsz4wwaaWFi37F2aGKpLwQgq40VTdDUKE=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-7yCA4a2NM20o7z757lbMtyvFC+72ScTd+N7AKWCH1KU=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeCheckInputs = [
		git
		jujutsu
	];

	# NOTE: no versionCheckHook.
	# Shockingly, this command does not have a `--version`.

	passthru.fromHead = lib.mkHeadFetch' self (self: {
		inherit self;
		cargoDeps = importCargoLock {
			lockFile = self.src + "/Cargo.lock";
			allowBuiltinFetchGit = true;
		};
	});

	meta = {
		homepage = "https://github.com/laulauland/jj-hunk";
		description = "Non-interactive hunk distribution in jj CLI";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# jj-hunk uses `jj split --message`, which was added in Jujutsu v0.30.0.
		# https://github.com/jj-vcs/jj/releases/tag/v0.30.0
		broken = lib.versionOlder jujutsu.version "0.30.0";
		mainProgram = "jj-hunk";
	};
}))
