{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo,
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
  version = "0.4.4";

  strictDeps = true;
  __structuredAttrs = true;
  doCheck = true;

  src = fetchFromGitHub {
    owner = "lusingander";
    repo = "serie";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-Uf7HYcN/lJc2TSl2dZQcOKyEeLHMb2RTQwSzXWZnBkw=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-NbBF747sSxmjlTbcYknNZFFsaIVZ6+wHhjMJ6akg4BU=";
  };
  cargoBuildType = "release";
  cargoCheckType = "test";

  nativeBuildInputs = [
    cargo
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
