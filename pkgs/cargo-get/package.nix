{
  lib,
  stdenv,
  fetchFromGitHub,
  rustHooks,
  rustPlatform,
  cargo,
  libiconv,
  testers,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform) optionalDarwin;
in stdenv.mkDerivation (self: {
  pname = "cargo-get";
  version = "1.4.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicolaiunrein";
    repo = "cargo-get";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-HqSZZ2wfS33lAXVzDjoL2gpcYZP/LtYM63ruDHdcHiY=";
  };

  cargoDeps = fetchCargoVendor {
    inherit (self) src;
    name = "${self.finalPackage.name}-cargo-deps";
    hash = "sha256-vDqpDZziWjrU9WSH1cWvJZwRtwNIAO/sJl2XnkLS0Ss=";
  };

  nativeBuildInputs = rustHooks.asList ++ [
    cargo
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
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "cargo-get";
  };
}))
