{
	lib,
	stdlib,
	stdenv,
	fetchFromGitLab,
	python3Packages,
	pythonHooks,
	versionCheckHook,
}: lib.callWith' python3Packages ({
	python,
	trio,
	jeepney,
	flit-core,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "dbus-trace";
	version = "0.1";

	outputs = [ "out" "dist" ];

	src = fetchFromGitLab {
		owner = "takluyver";
		repo = "dbus-trace";
		tag = "${self.version}";
		hash = "sha256-V/raOxkFRSpjN6v24wzwb50Qih+zWQKLuBRUWh20hHY=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		flit-core
	];

	propagatedBuildInputs = [
		trio
		jeepney
	];

	postFixupHooks = [ "wrapPythonPrograms" ];

	meta = {
		homepage = "https://gitlab.com/takluyver/dbus-trace";
		description = "Inspect the D-Bus messages a program sends and receives";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		mainProgram = "dbus-trace";
	};
}))

