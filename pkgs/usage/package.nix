{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libiconv,
}: lib.callWith' rustPlatform ({
  fetchCargoTarball,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform) optionalDarwin;
in stdenv.mkDerivation (self: {
  pname = "usage";
  version = "0.3.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jdx";
    repo = "usage";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-zjQjFrNaFgpCCuwogbNTNMHKzDDzwRNmzUMMOREzZSk=";
  };

  cargoDeps = fetchCargoTarball {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-BysmdrDjIUNlc7wb+l8/3qJnbU6zjmX+72NUhRkK+eo=";
  };

  cargoBuildType = "release";

  nativeBuildInputs = [
    cargoSetupHook
    cargoBuildHook
    cargoCheckHook
    cargoInstallHook
  ];

  buildInputs = optionalDarwin [
    libiconv
  ];

  passthru = {
    fromHead = lib.mkHeadFetch { self = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/jdx/usage";
    description = "A tool for CLI specifications";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.all;
    mainProgram = "usage";
  };
}))
