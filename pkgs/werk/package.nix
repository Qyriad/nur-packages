{
	lib,
	stdenv,
	stdlib,
	rustHooks,
	rustPlatform,
	cargo,
	fetchFromGitHub,
	versionCheckHook,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "werk";
	version = "0.2.0";

	doCheck = true;
	doInstallCheck = true;

	src = fetchFromGitHub {
		owner = "simonask";
		repo = "werk";
		# There's no tag.
		rev = "4560f4091eb39b9ac6e76e93d218df71ce3773c1";
		hash = "sha256-6VrU8YzyHR3sVtVMsyurN0j7kwIhF6COzVERGDWhq4Y=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-vendor";
		inherit (self) src;
		hash = "sha256-aNE2utV2R0xvrWhaM06zZ0GR2mTuCrZKQy8pPM5L7fw=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	env.COMMIT_HASH = self.src.rev;
	env.CARGO_PKG_VERSION = self.version;
	env.CI_COMMIT_TAG = self.src.rev;
	env.SHORT_COMMIT = "4560f409";

	passthru.fromHead = lib.mkHeadFetch' self (self: {
		cargoDeps = importCargoLock {
			lockFile = self.src + "/Cargo.lock";
			allowBuiltinFetchGit = true;
		};
	});

	postPatch = lib.dedent ''
		substituteInPlace "$NIX_BUILD_TOP/$sourceRoot/werk-cli/main.rs" \
			--replace-fail "build::COMMIT_HASH" "\"$COMMIT_HASH\""
	'';

	meta = {
		homepage = "https://simonask.github.io/werk";
		description = "Simplistic command runner and build system";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit asl20 ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder cargo.version "1.88.0";
		mainProgram = "werk";
	};
}))
