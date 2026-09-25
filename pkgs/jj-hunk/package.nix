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
	version = "0.5.1";

	src = fetchFromGitHub {
		owner = "laulauland";
		repo = "jj-hunk";
		tag = "v${self.version}";
		hash = "sha256-Pe0rLEUMXmq+8eUMmjuu5KvFJ/aN53bTQ6/1rE2YcT0=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-tO4oGY92AieYb1SY3ylWSkOlcIKadbZLKOY6nTzXo48=";
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
