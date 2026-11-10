{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	pythonHooks,
	python3Packages,
	versionCheckHook,
}: lib.callWith' python3Packages ({
	python,
	hatchling,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "termaid";
	version = "0.12.0";

	outputs = [ "out" "dist" ];

	src = fetchFromGitHub {
		owner = "fasouto";
		repo = "termaid";
		tag = "v${self.version}";
		hash = "sha256-UMDcmiDo17JS8Wn9OVhgfhZSA5Ks+fnxjGJDepF+R3g=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		hatchling
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	postFixupHooks = [ "wrapPythonPrograms" ];

	meta = {
		homepage = "https://github.com/fasouto/termaid";
		description = "Render Mermaid diagrams in your terminal or Python app";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		mainProgram = "termaid";
	};
}))
