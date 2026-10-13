{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	pkg-config,
	meson,
	cmake,
	ninja,
	versionCheckHook,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "";
	version = "";

	src = fetchFromGitHub {
		owner = "";
		repo = "";
		tag = "";
		hash = lib.fakeHash;
	};

	#dontUseCmakeConfigure = true;

	nativeBuildInputs = [
		pkg-config
		#meson
		#cmake
		ninja
	];

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	meta = {
		homepage = "";
		description = "";
		maintainers = with lib.maintainers; [ qyriad ];
		#license = with lib.licenses; [ ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		#mainProgram = "";
	};
})
