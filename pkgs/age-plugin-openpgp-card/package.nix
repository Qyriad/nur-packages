{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  pcsclite,
}: lib.callWith [ rustPlatform ] ({
  fetchCargoTarball,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: stdenv.mkDerivation (self: {
  pname = "age-plugin-openpgp-card";
  version = "0.1.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "wiktor-k";
    repo = "age-plugin-openpgp-card";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-uJmYtc+GxJZtCjLQla/h9vpTzPcsL+zbM2uvAQsfwIY=";
  };

  nativeBuildInputs = [
    cargoSetupHook
    cargoBuildHook
    cargoCheckHook
    cargoInstallHook
    pkg-config
  ];

  buildInputs = [
    pcsclite
  ];

  cargoDeps = fetchCargoTarball {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-3Qw9VU8c1HQcuZcUVexZbUTeSkJcAkpdJNyb5uQZl/M=";
  };
  cargoBuildType = "release";

  passthru = {
    fromHead = lib.mkHeadFetch { self = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/wiktor-k/age-plugin-openpgp-card";
    description = "Age plugin for using ed255519 on OpenPGP Card devices (Yubikeys, Nitrokeys)";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit asl20 ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    mainProgram = "age-plugin-openpgp-card";
  };
}))
