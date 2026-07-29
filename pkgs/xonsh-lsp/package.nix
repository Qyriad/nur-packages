{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	python3Packages,
	pythonHooks,
	tree-sitter-xonsh,
	versionCheckHook,
}: lib.callWith' python3Packages ({
	python,
	hatchling,
	cattrs,
	lsprotocol,
	pygls,
	tree-sitter,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "xonsh-lsp";
	version = "0.2.1";

	outputs = [ "out" "dist" ];

	src = fetchFromGitHub {
		owner = "FoamScience";
		repo = "xonsh-language-server";
		tag = "v${self.version}";
		hash = "sha256-3aM5nD8qBHt05df8ElPPstWZiICPOZrBqJqULZrJdLU=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		python
		hatchling
	];

	propagatedBuildInputs = [
		cattrs
		lsprotocol
		pygls
		tree-sitter
		tree-sitter-xonsh
		tree-sitter-xonsh.pythonBindings
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	postFixupHooks = [ "wrapPythonPrograms" ];

	meta = {
		homepage = "https://github.com/FoamScience/xonsh-language-server";
		description = "An LSP for Xonsh python-shell";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.any lib.id [
			(lib.versionOlder tree-sitter.version "0.25.2")
			# I *think* that's the version that introduced `pygls.lsp.server`?
			(lib.versionOlder pygls.version "2.0.0")
		];
		mainProgram = "xonsh-lsp";
	};
}))
