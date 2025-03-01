{
  lib,
  stdenv,
  rustPlatform,
  cargo,
  fetchFromGitHub,
  writeShellScriptBin,
  mkAbsoluteDylibsHook,
  nasm,
  cargo-about,
  wayland,
  libxkbcommon,
  dav1d,
  libheif,
  gdk-pixbuf,
  libglvnd,
  mesa,
  udev,
  vulkan-loader,
  xz,
  zlib,
  zstd,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformGetters stdenv.hostPlatform)
    getLibrary
  ;
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalLinux
  ;
in stdenv.mkDerivation (self: {
  pname = "simp";
  version = "3.6.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Kl4rry";
    repo = "simp";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-iLBTZdAWVeaGErfFbzZ9z0sQWYM0Vfa9wAA9O18Itfk=";
  };

  # simp's build.rs calls `git rev-parse`. We'll just fake it.
  fakeGit = writeShellScriptBin "git" ''
    if [[ "$1" == "rev-parse" ]]; then
      echo "v${self.version}"
    else
      echo "fake git script called with unknown arguments: $@"
      exit 1
    fi
  '';

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-geNFprvJB1+mb9ycj6yFmqE3rfqKWJNrZVBZc+pfYs0=";
  };
  cargoBuildType = "release";

  absoluteDylibsHook = mkAbsoluteDylibsHook {
    inherit (self.finalPackage) name;
    runtimeDependenciesFor."$out/bin/simp" = map (lib.applyTo getLibrary) [
      [ wayland "wayland-client" ]
      [ libxkbcommon "xkbcommon" ]
      [ libglvnd "GL" ]
      [ libglvnd "EGL" ]
      [ vulkan-loader "vulkan" ]
      [ zlib "z" ]
      [ zstd "zstd" ]
      [ xz "lzma" ]
    ];
  };

  nativeBuildInputs = [
    cargo
    cargoSetupHook
    cargoBuildHook
    cargoInstallHook
    self.fakeGit
    cargo-about
    nasm
  ] ++ optionalLinux [
    self.absoluteDylibsHook
  ];

  buildInputs = [
    dav1d
    libheif
    gdk-pixbuf
    libglvnd
    vulkan-loader
    zlib
    zstd
    xz
  ] ++ optionalLinux [
    wayland
    libxkbcommon
    mesa.drivers
    udev
  ];

  meta = {
    mainProgram = "simp";
  };
}))
