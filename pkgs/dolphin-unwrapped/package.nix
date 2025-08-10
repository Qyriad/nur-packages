{
  lib,
  stdenv,
  mkAbsoluteDylibsHook,
  kdePackages,
  pipewire,
  appstream,
}: lib.callWith' kdePackages ({
  dolphin,
}: let
  inherit (lib.mkPlatformGetters stdenv.hostPlatform)
    getLibrary
  ;
in dolphin.overrideAttrs (final: prev: {

  # So long as we link Pipewire at link-time by absolute path,
  # we don't need to wrap.
  dontWrapQtApps = true;
  dontWrapGApps = true;

  # Pipewire is `dlopen()`d.
  absoluteDylibsHook = mkAbsoluteDylibsHook {
    inherit (final.finalPackage) name;
    runtimeDependenciesFor."$out/bin/dolphin" = map (lib.splatTo getLibrary) [
      [ pipewire "pipewire-0.3" ]
    ];
  };

  nativeBuildInputs = prev.nativeBuildInputs ++ [
    final.absoluteDylibsHook
  ];

  buildInputs = prev.buildInputs ++ [
    appstream
    pipewire
  ];

  meta = prev.meta // {
    description = prev.meta.description + " (with absolute dylibs)";
  };
}))
