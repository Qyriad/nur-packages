{
  lib,
  stdenv,
  fetchzip,
  qt6Packages,
  alsa-lib,
  fluidsynth,
  libjack2,
  cmake,
  ninja,
  pkg-config,
  # All of these are theoretically optional:
  libsysprof-capture,
  libsndfile,
  pipewire,
  flac,
  libogg,
  libvorbis,
  libopus,
  libmpg123,
  libpulseaudio,
}: lib.callWith' qt6Packages ({
  qtbase,
  qttools,
}: stdenv.mkDerivation (self: {
  pname = "qsynth";
  version = "1.0.3";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchzip {
    url = "mirror://sourceforge/qsynth/qsynth-${self.version}.tar.gz";
    hash = "sha256-HvF0ITBKLINQ+cQJzcGsNsP/ks2CbypdWhDW00eigZg=";
  };

  outputs = [ "out" "man" ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  inherit fluidsynth;

  buildInputs = [
    alsa-lib
    self.fluidsynth
    libjack2
    qtbase
    qttools
    libsysprof-capture
    libsndfile
    pipewire
    flac
    libogg
    libvorbis
    libopus
    libmpg123
    libpulseaudio
  ];

  cmakeBuildType = "RelWithDebInfo";
  # Works fine without.
  dontWrapQtApps = true;

  meta = {
    description = "Fluidsynth GUI";
    mainProgram = "qsynth";
    homepage = "https://sourceforge.net/projects/qsynth";
    license = with lib.licenses; [ gpl2Plus] ;
    maintainers = with lib.maintainers; [ qyriad ];
    platforms = lib.platforms.linux;
  };
}))
