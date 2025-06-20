{
  lib,
  stdenv,
  fetchFromGitHub,
  rustHooks,
  rustPlatform,
  cargo,
  libiconv,
  testers,
  git,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
  importCargoLock,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "serie";
  version = "0.4.6";

  strictDeps = true;
  __structuredAttrs = true;
  doCheck = true;

  src = fetchFromGitHub {
    owner = "lusingander";
    repo = "serie";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-26B/bwXz60fcZrh6H1RPROiML44S1Pt1J3VrJh2gRrI=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-Bdk553tECJiMxJlXj147Sv2LzH+nM+/Cm5BpBr78I4o=";
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
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "serie";
  };
}))
