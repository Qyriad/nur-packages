{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: stdenv.mkDerivation (self: {
  pname = "wild";
  version = "0.5.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "davidlattimore";
    repo = "wild";
    rev = "refs/tags/${self.version}";
    hash = "sha256-tVGvSd4aege3xz/CrEl98AwuEJlsM3nVVG0urTSajFQ=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-dXIYJfjz6okiLJuX4ZHu0Ft2/9XDjCrvvl/eqeuvBkU=";
  };
  cargoBuildType = "release";

  nativeBuildInputs = [
    cargo
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
