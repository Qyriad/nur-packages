{
  lib,
  stdenv,
  fetchFromGitea,
  rustHooks,
  rustPlatform,
  cargo,
  libiconv,
  git,
  testers,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
  importCargoLock,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "mergiraf";
  version = "0.11.0";

  strictDeps = true;
  __structuredAttrs = true;
  doCheck = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "mergiraf";
    repo = "mergiraf";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-nzWRMCIeZ1RmZO4v5UqX1JrbN1UjBHkl/bYaERCzfew=";
  };

  cargoDeps = fetchCargoVendor {
    name = lib.suffixName self "cargo-deps";
    inherit (self) src;
    hash = "sha256-9OjcEmed9nLM/fp6Qk/Gh9hTVnn5cqCxTUpAJUkI4/M=";
  };

  nativeBuildInputs = rustHooks.asList ++ [
    cargo
  ];

  nativeCheckInputs = [
    git
  ];

  buildInputs = optionalDarwin [
    libiconv
  ];

  passthru = {
    tests.version = testers.testVersion { package = self.finalPackage; };
    fromHead = lib.mkHeadFetch {
      self = self.finalPackage;
      extraAttrs = self: {
        cargoDeps = importCargoLock {
          lockFile = self.src + "/Cargo.lock";
          allowBuiltinFetchGit = true;
        };
      };
    };
  };

  meta = {
    homepage = "https://mergiraf.org";
    description = "A syntax-aware git merge driver for a growing collection of programming languages and file formats";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ gpl3Only ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "mergiraf";
  };
}))

