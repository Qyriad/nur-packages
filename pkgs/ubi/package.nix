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
  fetchCargoTarball,
  importCargoLock,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "ubi";
  version = "0.6.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "houseabsolute";
    repo = "ubi";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-hvwK8yIDXg5SlBrV+Rl8MgbKlIhDVt87ANcdJahptyA=";
  };

  cargoDeps = fetchCargoTarball {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-N9f1XWLp3CzpUEed3rODEr/uyd4RrRwLkZp7HAJdbf4=";
  };

  doCheck = true;
  # The integration tests seem to have to preconditions.
  cargoTestFlags = [ "--lib" ];
  __darwinAllowLocalNetworking = self.finalPackage.doCheck;
  __noChroot = self.finalPackage.doCheck;

  nativeBuildInputs = rustHooks.asList ++ [
    cargo
  ];

  buildInputs = optionalDarwin [
    libiconv
  ];

  passthru = {
    fromHead = lib.mkHeadFetch {
      self = self.finalPackage;
      extraAttrs = self: {
        # Use IFD to get the latest Cargo dependencies too.
        cargoDeps = importCargoLock {
          lockFile = self.src + "/Cargo.lock";
          allowBuiltinFetchGit = true;
        };
      };
    };
    tests.version = testers.testVersion { package = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/houseabsolute/ubi";
    description = "Universal binary installer";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit asl20 ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    mainProgram = "ubi";
  };
}))
