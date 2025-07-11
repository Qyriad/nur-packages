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
  version = "0.10.4";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "sectordistrict";
    repo = "intentrace";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-zVRH6uLdBXI6VTu/R3pTNCjfx25089bYYTJZdvZIFck=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-1n0fXOPVktqY/H/fPCgl0rA9xZM8QRXvZQgTadfwymo=";
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
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "intentrace";
  };
}))
