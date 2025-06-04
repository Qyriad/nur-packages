{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libiconv,
  cargo,
  rustHooks,
  testers,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
  importCargoLock,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
    ;
in stdenv.mkDerivation (self: {
  pname = "binsider";
  version = "0.2.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "orhun";
    repo = "binsider";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-FNaYMp+vrFIziBzZ8//+ppq7kwRjBJypqsxg42XwdEs=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-ZoZbhmUeC63IZ5kNuACfRaCsOicZNUAGYABSpCkUCXA=";
  };

  nativeBuildInputs = rustHooks.asList ++ [
    cargo
  ] ++ optionalDarwin [
    libiconv
  ];

  passthru.tests = testers.testVersion { package = self.finalPackage; };
  passthru.fromHead = lib.mkHeadFetch {
    self = self.finalPackage;
    extraAttrs = self: {
      cargoDeps = importCargoLock {
        lockFile = self.src + "/Cargo.lock";
        allowBuiltinFetchGit = true;
      };
    };
  };

  meta = {
    homepage = "https://binsider.dev";
    description = "Analyze ELF binaries like a boss";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "binsider";
  };
}))
