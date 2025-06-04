{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  cargo,
  nix-update-script,
  testers,
}: lib.callWith [ darwin rustPlatform ] ({
  apple_sdk,
  libiconv,
  DarwinTools,
  fetchCargoVendor,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "pik";
  version = "0.23.1";

  strictDeps = true;
  __structuredAttrs = true;
  doCheck = true;

  src = fetchFromGitHub {
    owner = "jacek-kurlit";
    repo = "pik";
    rev = "refs/tags/${self.version}";
    hash = "sha256-ol2jILlSmCVLieNzyo4UnzeIn+Xy2Sh03ZyfG2oABcM=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-t9iGHmwB533Jk5sJ6XmOg2OVaD+PgsKaQQ66QjQxdNY=";
  };
  cargoBuildType = "release";
  cargoCheckType = "test";

  nativeBuildInputs = [
    cargo
    cargoSetupHook
    cargoBuildHook
    cargoCheckHook
    cargoInstallHook
  ] ++ optionalDarwin [
    DarwinTools
  ];

  buildInputs = optionalDarwin [
    libiconv
    apple_sdk.IOKit
  ];

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = self.finalPackage; };
    fromHead = lib.mkHeadFetch { self = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/jacek-kurlit/pik";
    description = "Process interactive kill";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    # lol with doesn't shadow.
    mainProgram = "pik";
  };
}))

