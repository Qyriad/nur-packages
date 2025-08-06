{
  lib,
  stdenv,
  fetchFromGitHub,
  kdePackages,
  qt6Packages,
  cmake,
  ninja,
  pkg-config,
  alsa-lib,
  jack2,
  portaudio,
  versionCheckHook,
}: lib.callWith [ kdePackages qt6Packages ] ({
  qtbase,
  qtsvg,
  qttools,
  qtutilities,
}: stdenv.mkDerivation (self: {
  pname = "qjackctl";
  version = "1.0.4";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rncbc";
    repo = "qjackctl";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-eZ3PBacRdMJCHHwE0qYi4jgSb7G7uS2Q+j02EdnSYqA=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    versionCheckHook
  ];

  buildInputs = [
    qtbase
    qtsvg
    qttools
    alsa-lib
    jack2
    portaudio
  ];

  cmakeFlags = [
    "-DCONFIG_JACK_VERSION=1"
    "-DCONFIG_WAYLAND=1"
  ];

  cmakeBuildType = "RelWithDebInfo";

  # Unncecessary. Works fine without wrapping.
  dontWrapQtApps = true;

  versionCheckProgramArg = "--version";

  passthru.fromHead = lib.mkHeadFetch { self = self.finalPackage; };

  meta = {
    homepage = "https://qjackctl.sourceforge.io/";
    description = "JACK Audio Connection Kit Qt GUI Interface";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "qjackctl";
  };
}))
