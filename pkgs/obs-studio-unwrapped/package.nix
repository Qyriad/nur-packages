{
	lib,
	stdenv,
	mkAbsoluteDylibsHook,
	obs-studio,
	libGL,
	libvlc,
	libsysprof-capture,
	rnnoise,
}: let
	inherit (lib.mkPlatformGetters stdenv.hostPlatform)
		getLibrary;
in obs-studio.overrideAttrs (final: prev: {
	dontWrapQtApps = stdenv.hostPlatform.isLinux;
	dontWrapGApps = true;

	absoluteDylibsHook = mkAbsoluteDylibsHook {
		inherit (final.finalPackage) name;
		runtimeDependenciesFor."$out/bin/obs" = [
			(getLibrary libGL "GL")
			(getLibrary libvlc "vlc")
			"$out/lib/libobs-opengl.so"
			"$out/lib/obs-plugins/decklink.so"
		];
	};

	buildInputs = prev.buildInputs ++ [
		libsysprof-capture
		rnnoise
	];

	nativeBuildInputs = prev.nativeBuildInputs ++ [
		final.absoluteDylibsHook
	];

	meta = prev.meta // {
		description = prev.meta.description + " (with absolute dylibs)";
	};
})
