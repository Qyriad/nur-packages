{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo,
  libiconv,
  testers,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
  cargoSetupHook,
  cargoBuildHook,
  cargoInstallHook
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform) optionalDarwin;
in stdenv.mkDerivation (self: {
  pname = "cargo-get";
  version = "1.1.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicolaiunrein";
    repo = "cargo-get";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-BE7BlkX6uhgclLjeRX7iAbF2+K5tksF3fzh5SU2AJs4=";
  };

  cargoBuildType = "release";
  cargoDeps = fetchCargoVendor {
    inherit (self) src;
    name = "${self.finalPackage.name}-cargo-deps";
    hash = "sha256-7WxqaAVUEojjpOvrobM+CQVtk7EtuJHev61X30C3EDY=";
  };

  nativeBuildInputs = [
    cargo
    cargoSetupHook
    cargoBuildHook
    cargoInstallHook
  ];

  buildInputs = optionalDarwin [
    libiconv
  ];

  passthru = {
    tests.version = testers.testVersion { package = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/nicolaiunrein/cargo-get";
    description = "Query package information from Cargo.toml files in a script-friendly way";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit asl20 ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    mainProgram = "cargo-get";
  };
}))
