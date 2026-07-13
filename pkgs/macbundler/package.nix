{
	lib,
	stdenvNoCC,
	stdlib,
	fetchFromGitHub,
	pythonHooks,
	python3Packages,
}: lib.callWith' python3Packages ({
	python,
	hatchling,
}: let
	stdenv = stdenvNoCC;
in stdlib.makePackage stdenv (self: {
	pname = "macbundler";
	version = "0.2.3";

	outputs = [ "out" "dist" ];

	src = fetchFromGitHub {
		owner = "shakfu";
		repo = "macbundler";
		tag = "${self.version}";
		hash = "sha256-HMnwW1GfURxKO5oz0hxYVd8Eleva2u0t+G5d65wEuJk=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		hatchling
	];

	postFixup = "wrapPythonPrograms";

	meta = {
		description = "Tools to create macOS bundles";
		homepage = "https://github.com/shakfu/macbundler";
		license = with lib.licenses; [ gpl3Plus ];
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		mainProgram = "macbundler";
	};
}))
