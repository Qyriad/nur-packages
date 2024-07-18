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
  importCargoLock,
  cargoSetupHook,
  cargoBuildHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "otree";
  version = "0.2.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "fioncat";
    repo = "otree";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-M6xmz7aK+NNZUDN8NJCUEODwotJ9VeY3bsueFpwjjjs=";
  };

  cargoBuildType = "release";
  cargoDeps = importCargoLock {
    lockFile = builtins.path {
      path = lib.joinPaths [ self.src "Cargo.lock" ];
      name = "Cargo.lock";
    };
    # Mini hack. fromHead uses an eval fetch and so src isn't a derivation, and right
    # after upstream tagged a release they removed tui-tree-widget as a git dependency.
    outputHashes = lib.optionalDefault (lib.isDerivation self.src) {
      "tui-tree-widget-0.20.0" = "sha256-/uLp63J4FoMT1rMC9cv49JAX3SuPvFWPtvdS8pspsck=";
    };
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
