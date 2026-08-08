{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	cmake,
	ninja,
	pkg-config,
	alsa-lib,
	libGL,
	libx11 ? libX11,
	libX11 ? throw "older Nixpkgs has libX11",
	libxcomposite ? libXcomposite,
	libXcomposite ? throw "older Nixpkgs has libXcomposite",
	libxcursor ? libXcursor,
	libXcursor ? throw "older Nixpkgs has libXcursor",
	libxext ? libXext,
	libXext ? throw "older Nixpkgs has libXext",
	libxinerama ? libXinerama,
	libXinerama ? throw "older Nixpkgs has libXinerama",
	libxrandr ? libXrandr,
	libXrandr ? throw "older Nixpkgs has libXrandr",
	libxi ? libXi,
	libXi ? throw "older Nixpkgs has libXi",
	fontconfig,
	freetype,
	juce,
	libspecbleach-full,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
		optionalLinux
		optionalDarwin
	;
in {
	pname = "noise-repellent";
	version = "0.4.1";

	src = fetchFromGitHub {
		owner = "lucianodato";
		repo = "noise-repellent";
		tag = "v${self.version}";
		hash = "sha256-cv2eqY4x5Nj2nFVKTYwY1mYCkv5/icM2cGw4cN225ug=";
	};

	nativeBuildInputs = [
		pkg-config
		cmake
		ninja
	];

	cmakeFlags = [
		(lib.cmakeBool "USE_SYSTEM_FREETYPE" true)
		(lib.cmakeBool "USE_SYSTEM_SPECBLEACH" true)
		(lib.cmakeBool "USE_SYSTEM_JUCE" true)
		(lib.cmakeBool "ENABLE_PLUGIN_TESTS" self.doCheck)
	] ++ optionalDarwin [
		# Their default install directories are absolute `/Library/…`.
		"-DINSTALL_VST3_DIR=${placeholder "out"}/Library/Audio/Plug-Ins/VST3"
		"-DINSTALL_AU_DIR=${placeholder "out"}/Library/Audio/Plug-Ins/Components"
		"-DINSTALL_LV2_DIR=${placeholder "out"}/Library/Audio/Plug-Ins/LV2"
	];

	buildInputs = [
		fontconfig
		freetype
		juce
		libspecbleach-full
	] ++ optionalLinux [
		alsa-lib
		libGL
		libx11
		libxcomposite
		libxcursor
		libxext
		libxinerama
		libxrandr
		libxi
	];

	meta = {
		homepage = "https://github.com/lucianodato/noise-repellent";
		description = "A JUCE plugin for broadband noise reduction (VST, LV2)";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ gpl3 ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
	};
})
