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
	version = "0.10.1";

	doCheck = true;
	doInstallCheck = true;

	outputs = [ "out" "man" ];

	src = fetchFromGitHub {
		owner = "pamburus";
		repo = "termframe";
		tag = "v${self.version}";
		hash = "sha256-y8VmLLuajNnECuxQ7f9xmIDJXvMDs4SJ+B9cj8D2BLw=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-w0LKH1nEAiiZpgmJFE5vZARd62e7IU+4HED8CVsWCG4=";
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
		broken = lib.versionOlder cargo.version "1.95.0";
		outputsToInstall = [ "out" "man" ];
		mainProgram = "termframe";
	};
}))
