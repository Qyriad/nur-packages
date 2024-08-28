{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}: lib.callWith' rustPlatform ({
  fetchCargoTarball,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: stdenv.mkDerivation (self: {
  pname = "wild";
  version = "0.2.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "davidlattimore";
    repo = "wild";
    rev = "refs/tags/${self.version}";
    hash = "sha256-07fBScwJc7vmGIkKVMuatz8EMq5wc5ISpLPt7FTIR6g=";
  };

  cargoDeps = fetchCargoTarball {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-pjhMQBIhvSkvHS3p12J93tUDHEPkRSih6DKAFslNq6E=";
  };
  cargoBuildType = "release";

  nativeBuildInputs = [
    cargoSetupHook
    cargoBuildHook
    cargoCheckHook
    cargoInstallHook
  ];

  meta = {
    homepage = "https://github.com/davidlattimore/wild";
    description = "A linker with the goal of being very fast for iterative development";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit /* apache */ ];
    platforms = lib.platforms.linux;
    mainProgram = "wild";
  };
}))
