{
	lib,
	stdenv,
	stdlib,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	versionCheckHook,
	installShellFiles,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "termframe";
	version = "0.8.8";

	doCheck = true;
	doInstallCheck = true;

	outputs = [ "out" "man" ];

	src = fetchFromGitHub {
		owner = "pamburus";
		repo = "termframe";
		tag = "v${self.version}";
		hash = "sha256-RCT8kNnYwIEmRoO5cI3aPxbF0Dpo+F6/OEKPXPe/KdA=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-gA7ObfcxWWzFXIRlRcnhighSBGODBP0XCIZNiM8ysbY=";
	};

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
		installShellFiles
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	postInstall = lib.dedent ''
		PATH="$out/bin:$PATH"
		installShellCompletion --cmd termframe \
			--bash <(termframe --shell-completions bash) \
			--fish <(termframe --shell-completions fish) \
			--zsh <(termframe --shell-completions zsh)

		installManPage --name termframe.1 <(termframe --man-page)
	'';

	passthru.fromHead = lib.mkHeadFetch' self (self: {
		cargoDeps = importCargoLock {
			lockFile = self.src + "/Cargo.lock";
			allowBuiltinFetchGit = true;
		};
	});

	meta = {
		homepage = "https://github.com/pamburus/termframe";
		description = "Terminal output SVG screenshot tool";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder cargo.version "1.91.0";
		outputsToInstall = [ "out" "man" ];
		mainProgram = "termframe";
	};
}))
