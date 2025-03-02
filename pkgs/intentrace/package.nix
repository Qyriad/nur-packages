{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  rustPlatform,
  cargo,
}: lib.callWith [ darwin rustPlatform ] ({
  libiconv,
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
  pname = "intentrace";
  version = "0.4.2";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "sectordistrict";
    repo = "intentrace";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-ZcGZK4GX78ls3nHb7SBKszmZXMAbCxS4osW3MLqgnHQ=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-Z3T4mupwUqOSP+iAmy7Ps1EZlyV9cDvnfXBZwH1NFaA=";
  };
  cargoBuildType = "release";

  nativeBuildInputs = [
    cargo
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
