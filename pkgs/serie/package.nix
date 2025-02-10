{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libiconv,
  testers,
  git,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
  importCargoLock,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "serie";
  version = "0.4.1";

  strictDeps = true;
  __structuredAttrs = true;
  doCheck = true;

  src = fetchFromGitHub {
    owner = "lusingander";
    repo = "serie";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-F7AlDuvRYCMhOXyzg9/oTukAEaDJENG0ZEhIlNe+Cic=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-zQLmiutRYJzrr6Ir3nC4CebuwHPM00Gc4O0gpwjFBWo=";
  };
  cargoBuildType = "release";
  cargoCheckType = "test";

  nativeBuildInputs = [
    cargoSetupHook
    cargoBuildHook
    cargoCheckHook
    cargoInstallHook
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
      headRef = "master";
      extraAttrs = self: {
        cargoDeps = importCargoLock {
          lockFile = self.src + "/Cargo.lock";
          allowBuiltinFetchGit = true;
        };
      };
    };
  };

  meta = {
    homepage = "https://github.com/lusingander/serie";
    description = "A rich git commit graph in your terminal, like magic 📚";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    mainProgram = "serie";
  };
}))
