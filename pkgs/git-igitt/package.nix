{
  lib,
  stdenv,
  fetchFromGitHub,
  rustHooks,
  rustPlatform,
  rustc,
  zlib,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
  importCargoLock,
}: stdenv.mkDerivation (self: {
  pname = "git-igitt";
  version = "0.1.18";

  strictDeps = true;
  __structuredAttrs = true;
  doCheck = true;

  src = fetchFromGitHub {
    owner = "mlange-42";
    repo = "git-igitt";
    rev = "refs/tags/0.1.18";
    hash = "sha256-JXEWnekL9Mtw0S3rI5aeO1HB9kJ7bRJDJ6EJ4ATlFeQ=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.pname}-cargo-deps-${self.version}";
    inherit (self) src;
    hash = "sha256-ndxxkYMFHAX6uourCyUpvJYcZCXQ5X2CMX4jTJmNRiQ=";
  };

  nativeBuildInputs = rustHooks.asList ++ [
    rustc
  ];

  buildInputs = [
    zlib
  ];

  passthru.fromHead = lib.mkHeadFetch {
    self = self.finalPackage;
    headRef = "master";
    extraAttrs = self: {
      # Use IFD to get the latest Cargo dependencies too.
      cargoDeps = importCargoLock {
        lockFile = self.src + "/Cargo.lock";
        allowBuiltinFetchGit = true;
      };
    };
  };

  meta = {
    homepage = "https://github.com/mlange-42/git-igitt";
    description = "Interactive, cross-platform Git terminal application with clear git graphs arranged for your branching model";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    mainProgram = "git-igitt";
  };
}))
