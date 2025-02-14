{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
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

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-mL1n4fDbr8SAyVOLk5wyYhjbh0mWqLXPx0xWXu/4Wp8=";
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
    license = with lib.licenses; [ mit asl20 ];
    platforms = lib.platforms.linux;
    mainProgram = "wild";
  };
}))
