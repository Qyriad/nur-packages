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
}))
