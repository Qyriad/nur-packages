{
  lib,
  stdenv,
  rustHooks,
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
}: let
  inherit (lib.mkPlatformGetters stdenv.hostPlatform)
    getLibrary
  ;
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalLinux
  ;
in stdenv.mkDerivation (self: {
  pname = "simp";
  version = "3.9.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Kl4rry";
    repo = "simp";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-G2xA5UPRMpz2XVyWFzJvU4bNmpEYfOmKIEEmSeF3EiM=";
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
    hash = "sha256-j2bP2mrfm59W7DlFh6HNHaNmlKlVup07ttmXzgPLMfM=";
  };

  absoluteDylibsHook = lib.optionalDrvAttr stdenv.isLinux (mkAbsoluteDylibsHook {
    inherit (self.finalPackage) name;
    # Wow, 7 months later and this is some of the wildest Nix code we've written.
    runtimeDependenciesFor."$out/bin/simp" = map (lib.splatTo getLibrary) [
      [ wayland "wayland-client" ]
      [ libxkbcommon "xkbcommon" ]
      [ libglvnd "GL" ]
      [ libglvnd "EGL" ]
      [ vulkan-loader "vulkan" ]
      [ zlib "z" ]
      [ zstd "zstd" ]
      [ xz "lzma" ]
    ];
  });

  nativeBuildInputs = rustHooks.asList ++ [
    cargo
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
    mesa
    udev
  ];

  meta = {
    mainProgram = "simp";
    broken = true;
  };
}))
