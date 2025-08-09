{
  lib,
  stdenv,
  mkAbsoluteDylibsHook,
  obs-studio,
  libGL,
  libvlc,
}: let
  inherit (lib.mkPlatformGetters stdenv.hostPlatform)
    getLibrary;
in obs-studio.overrideAttrs (final: prev: {
  dontWrapQtApps = stdenv.hostPlatform.isLinux;

  absoluteDylibsHook = mkAbsoluteDylibsHook {
    inherit (final.finalPackage) name;
    runtimeDependenciesFor."$out/bin/obs" = [
      (getLibrary libGL "libGL")
      (getLibrary libvlc "libvlc")
      "$out/lib/libobs-opengl.so"
      "$out/lib/obs-plugins-decklink.so"
    ];
  };

  nativeBuildInputs = prev.nativeBuildInputs ++ [
    final.absoluteDylibsHook
  ];

  meta = prev.meta // {
    description = prev.meta.description + " (with absolute dylibs)";
  };
})
