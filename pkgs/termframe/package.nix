{
	lib,
	stdenv,
	fetchFromGitHub,
	rustHooks,
	rustPlatform,
	cargo,
	versionCheckHook,
	installShellFiles,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
	importCargoLock,
}: stdenv.mkDerivation (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "termframe";
	version = "0.8.1";

	strictDeps = true;
	__structuredAttrs = true;

	doCheck = true;
	doInstallCheck = true;

	outputs = [ "out" "man" ];

	src = fetchFromGitHub {
		owner = "pamburus";
		repo = "termframe";
		tag = "v${self.version}";
		hash = "sha256-rW+45Idx2cehFOLxo6KJwVYLEuxlb+olZEQU7mn0HZg=";
	};

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-J8ceIWwhSb0pyiccVAGxJIcAkMNZS72uqUa8PU+ttRM=";
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
