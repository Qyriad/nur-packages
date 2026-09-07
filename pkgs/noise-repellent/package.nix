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
	fontconfig,
	freetype,
	juce,
	libspecbleach-full,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "noise-repellent";
	version = "0.4.1";

	src = fetchFromGitHub {
		owner = "lucianodato";
		repo = "noise-repellent";
		tag = "v${self.version}";
		hash = "sha256-Ar0apmKd8a/7NXQlPXRPjuc5KpAQEUOsRrlOhNNO5YM=";
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
	];

	buildInputs = [
		alsa-lib
		libGL
		libx11
		libxcomposite
		libxcursor
		libxext
		libxinerama
		libxrandr
		fontconfig
		freetype
		juce
		libspecbleach-full
	];

	meta = {
		homepage = "https://github.com/lucianodato/noise-repellent";
		description = "A JUCE plugin for broadband noise reduction (VST, LV2)";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ gpl3 ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
	};
})
