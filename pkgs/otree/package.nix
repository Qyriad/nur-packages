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
  fetchCargoVendor,
  cargoSetupHook,
  cargoBuildHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "otree";
  version = "0.4.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "fioncat";
    repo = "otree";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-1p7Iep61m0mtaSiBj1T9d/wwzVGzXYOvbPv8isjhwjM=";
  };

  cargoBuildType = "release";
  cargoDeps = fetchCargoVendor {
    inherit (self) src;
    name = "${self.finalPackage.name}-cargo-deps";
    hash = "sha256-xHy6/zx5V51KOM+Hxmumr9o0hcO9tTlG1DJdfBrYSmE=";
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
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "otree";
  };
}))
