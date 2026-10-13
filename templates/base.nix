{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
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

	nativeBuildInputs = [
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
