{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  nix-update-script,
  testers,
}: lib.callWith [ darwin rustPlatform ] ({
  libiconv,
  DarwinTools,
  fetchCargoTarball,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalLinux
    optionalDarwin
  ;
  inherit (stdenv) hostPlatform buildPlatform;
in stdenv.mkDerivation (self: {
  pname = "pik";
  version = "0.6.4";

  strictDeps = true;
  __structuredAttrs = true;
  doCheck = true;

  src = fetchFromGitHub {
    owner = "jacek-kurlit";
    repo = "pik";
    rev = "refs/tags/${self.version}";
    hash = "sha256-lVwvYrl5AqWrDZ9vKFgiyibIb9tH0VaMWZtxrPAZV7E=";
  };

  cargoDeps = fetchCargoTarball {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-7a+QKSJb8NZm1RCiTdUqIzwXkdBTuC4X5GhOMC7iSrQ=";
  };
  cargoBuildType = "release";
  cargoCheckType = "test";

  nativeBuildInputs = [
    cargoSetupHook
    cargoBuildHook
    cargoCheckHook
    cargoInstallHook
  ] ++ optionalDarwin [
    DarwinTools
  ];

  buildInputs = optionalDarwin [
    libiconv
  ];

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = self.finalPackage; };
    fromHead = lib.mkHeadFetch { self = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/jacek-kurlit/pik";
    description = "Process interactive kill";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    # lol with doesn't shadow.
    mainProgram = "pik";
  };
}))

