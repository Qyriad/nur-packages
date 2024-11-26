{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  rustPlatform,
}: lib.callWith [ darwin rustPlatform ] ({
  libiconv,
  fetchCargoTarball,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "intentrace";
  version = "0.2.6";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "sectordistrict";
    repo = "intentrace";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-e47hauVg5Ncp0C5y6RkfKfxMHbBvpKrVoUq3aJxTf2E=";
  };

  cargoDeps = fetchCargoTarball {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-0j7gpKKCVzr+36yibqmIzDETAbcENKLR0HVnRWvb/mM=";
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
    homepage = "https://github.com/sectordistrict/intentrace";
    description = "strace with intent";
    longDescription = ''
      intentrace is strace with intent, it goes all the way for you instead of half the way. intentrace is currently in beta
    '';
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    mainProgram = "intentrace";
  };
}))
