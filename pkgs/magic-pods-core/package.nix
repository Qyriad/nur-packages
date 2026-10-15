{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	pkg-config,
	cmake,
	ninja,
	bluez,
	ffmpeg,
	libpulseaudio,
	nlohmann_json,
	openssl,
	sdbus-cpp,
	tomlplusplus,
	zlib,
	versionCheckHook,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "magic-pods-core";
	version = "2026-10-10";

	src = fetchFromGitHub {
		owner = "haileyok";
		repo = "MagicPodsCore";
		# hailey/handoff
		rev = "09a9b1f663375ec8d1c5123ad8e0f87fc73dd2bf";
		hash = "sha256-UqoFY4O37z3xOYoYZYQGCTLV7zToqYxLwvQk9y9yw0g=";
	};

	srcUsockets = fetchFromGitHub {
		owner = "uNetworking";
		repo = "uSockets";
		tag = "v0.8.7";
		hash = "sha256-vf3xI5GOqTEZx8iXf133nQvhUylIRzJ3jGuNUcQk9nY=";
	};

	srcUwebsockets = fetchFromGitHub {
		owner = "uNetworking";
		repo = "uWebSockets";
		tag = "v20.58.0";
		hash = "sha256-XSyX6iP+wlUcmBMdfvNyf/uFCzQGmogIS5ehUnRdWs0=";
	};

	nativeBuildInputs = [
		pkg-config
		cmake
		ninja
	];

	buildInputs = [
		bluez
		ffmpeg
		libpulseaudio
		nlohmann_json
		openssl
		sdbus-cpp
		tomlplusplus
		zlib
	];

	cmakeFlags = [
		"-DCMAKE_CXX_FLAGS=-Wno-error=non-pod-varargs"
		"-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
		# …why are these two "_CONTENT" but the other two aren't?
		"-DFETCHCONTENT_SOURCE_DIR_USOCKETS_CONTENT=${self.srcUsockets}"
		"-DFETCHCONTENT_SOURCE_DIR_UWEBSOCKETS_CONTENT=${self.srcUwebsockets}"
		"-DFETCHCONTENT_SOURCE_DIR_TOMLPLUSPLUS=${tomlplusplus.src}"
		"-DFETCHCONTENT_SOURCE_DIR_NLOHMANN_JSON=${nlohmann_json.src}"
	];

	# Upstream doesn't mark their targets with `install()`.
	dontUseNinjaInstall = true;

	installPhase = lib.dedent ''
		install -D -m u=rwx,g=rx,o=rx --target-directory="$out/bin" "$NIX_BUILD_TOP/$sourceRoot/$cmakeBuildDir/magicpodscore"
	'';

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	preVersionCheckHooks = [
		"version=2.0.10"
	];

	# Needed for older Nixpkgs, as the command name is `magicpodscore`, not `magic-pods-core`.
	versionCheckProgram = "${placeholder "out"}/bin/magicpodscore";

	meta = {
		homepage = "https://github.com/haileyok/MagicPodsCore/tree/hailey/handoff";
		description = "MagicModsCore, handoff branch";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ gpl3Only ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		mainProgram = "magicpodscore";
	};
})
