{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libiconv,
  cargo,
}: lib.callWith' rustPlatform ({
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
  pname = "binsider";
  version = "0.1.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "orhun";
    repo = "binsider";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-+QgbSpiDKPTVdSm0teEab1O6OJZKEDpC2ZIZ728e69Y=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-kxNE/3ToI1fv8RWVuIEdyBw7ozr+TRTf4yWvTK9kDp8=";
  };
  cargoBuildType = "release";

  nativeBuildInputs = [
    cargo
    cargoSetupHook
    cargoBuildHook
    cargoCheckHook
    cargoInstallHook
  ] ++ optionalDarwin [
    libiconv
  ];

  meta = {
    homepage = "https://binsider.dev";
    description = "Analyze ELF binaries like a boss";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "binsider";
  };
}))
