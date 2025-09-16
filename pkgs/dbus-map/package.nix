{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  glib,
  libxml2,
  procps,
}: stdenv.mkDerivation (self: {
  pname = "dbus-map";
  version = "2019-09-22";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "taviso";
    repo = "dbusmap";
    rev = "6bb2831d0ce0443e2ccc33f9493716d731c11937";
    hash = "sha256-s9g8M2AYd6GwGTkHuAPB7jkR/mVaSsq8h/yCvdm7gjw=";
  };

  glibOut = lib.getOutput "out" glib;
  glibDev = lib.getDev glib;

  postConfigure = ''
    echo | gcc -E -Wp,-v -
    pkg-config --cflags glib-2.0
    appendToVar NIX_CFLAGS_COMPILE "-I$glibOut/lib/glib-2.0/include"
    appendToVar NIX_CFLAGS_COMPILE "-I$glibDev/include/glib-2.0"
    export NIX_DEBUG=5
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    libxml2
    procps
  ];

  meta = {
    mainProgram = "dbus-map";
    maintainers = with lib.maintainers; [ qyriad ];
  };
})
