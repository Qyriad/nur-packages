{
  lib,
  stdenv,
  fetchFromGitHub,
  darwin,
  rustPlatform,
  rustc,
  cargo,
  libiconv,
  nix-update-script,
  testers,
}: lib.callWith' rustPlatform ({
  fetchCargoTarball,
  cargoSetupHook,
  cargoBuildHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "otree";
  version = "0.3.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "fioncat";
    repo = "otree";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-WvoiTu6erNI5Cb9PSoHgL6+coIGWLe46pJVXBZHOLTE=";
  };

  cargoBuildType = "release";
  cargoDeps = fetchCargoTarball {
    inherit (self) src;
    name = "${self.finalPackage.name}-cargo-deps";
    hash = "sha256-CzDpwCcV7Bae192oiR1ELBTvfEYJU1RAYb25rJksskg=";
  };

  nativeBuildInputs = [
    cargoSetupHook
    cargoBuildHook
    cargoInstallHook
    cargo
    rustc
  ];

  buildInputs = optionalDarwin [
    libiconv
    darwin.apple_sdk.frameworks.IOKit
  ];

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = self.finalPackage; };
    fromHead = lib.mkHeadFetch { self = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/fioncat/otree";
    description = "Command line tool to view objects (JSON/YAML/TOML) in a TUI tree widget";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    mainProgram = "otree";
  };
}))
