{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  rustHooks,
  cargo,
  versionCheckHook,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
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

  versionCheckProgramArg = "--version";

  nativeBuildInputs = rustHooks.asList ++ [
    cargo
  ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    homepage = "https://github.com/davidlattimore/wild";
    description = "A linker with the goal of being very fast for iterative development";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit asl20 ];
    platforms = lib.platforms.linux;
    # Rust 2024 edition was stablized in Rust 1.85.
    broken = lib.versionOlder cargo.version "1.85.0";
    mainProgram = "wild";
  };
}))
