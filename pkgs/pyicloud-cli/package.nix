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
	pythonRelaxDepsHook,
	setuptools-scm,
	certifi,
	cryptography,
	fido2,
	keyring,
	keyrings-alt,
	protobuf,
	pydantic,
	requests,
	srp,
	# Older Nixpkgs doesn't have tinyhtml.
	tinyhtml ? null,
	typing-extensions,
	tzlocal,
	click,
	rich,
	typer,
	pytestCheckHook,
	pytest,
	pytest-asyncio,
	pytest-cov,
	pytest-socket,
	pytest-timeout,
	types-requests,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "pyicloud-cli";
	version = "2.7.0";

	outputs = [ "out" "dist" ];

	src = fetchFromGitHub {
		owner = "timlaing";
		repo = "pyicloud";
		tag = "${self.version}";
		hash = "sha256-XQIE85fpod+Wmgg8t3PgHo8Vn2sF91h/I5hSvrCBSrk=";
	};

	nativeBuildInputs = (pythonHooks python).asList ++ [
		pythonRelaxDepsHook
		setuptools-scm
	];

	pythonRelaxDeps = [ "tzlocal" ];

	propagatedBuildInputs = [
		certifi
		cryptography
		fido2
		keyring
		keyrings-alt
		protobuf
		pydantic
		requests
		srp
		tinyhtml
		typing-extensions
		tzlocal
		click
		rich
		typer
	];

	nativeInstallCheckInputs = [
		pytestCheckHook
		versionCheckHook
		pytest
		pytest-asyncio
		pytest-cov
		pytest-socket
		pytest-timeout
		types-requests
	];

	# Needed for older Nixpkgs, as the command name is not pname.
	versionCheckProgram = "${placeholder "out"}/bin/${self.meta.mainProgram}";

	postFixupHooks = [ "wrapPythonPrograms" ];

	meta = {
		homepage = "https://github.com/timlaing/pyicloud";
		description = "A Python wrapper for accessing data from iCloud webservices";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# Not available on older Nixpkgs.
		broken = tinyhtml == null;
		mainProgram = "icloud";
	};
}))
