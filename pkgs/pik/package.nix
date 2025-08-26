{
  lib,
  stdenv,
  darwin,
  apple-sdk,
  fetchFromGitHub,
  rustPlatform,
  rustHooks,
  cargo,
  versionCheckHook,
}: lib.callWith [ darwin rustPlatform ] ({
  libiconv,
  DarwinTools,
  fetchCargoVendor,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "pik";
  version = "0.25.0";

  strictDeps = true;
  __structuredAttrs = true;

  doCheck = true;
  doInstallCheck = true;

  __darwinAllowLocalNetworking = self.finalPackage.doCheck;

  src = fetchFromGitHub {
    owner = "jacek-kurlit";
    repo = "pik";
    rev = "refs/tags/${self.version}";
    hash = "sha256-3ZYABdrODJJ9RUlhL7mIu/py3GCIFG3AUXQuol7o1Zs=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-333MHDuHYKlTUXSm2C19ZRPXeEGDxbQEImdsleUt1QU=";
  };

  versionCheckProgramArg = "--version";

  nativeBuildInputs = rustHooks.asList ++ [
    cargo
  ] ++ optionalDarwin [
    DarwinTools
  ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    fromHead = lib.mkHeadFetch { self = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/jacek-kurlit/pik";
    description = "Process interactive kill";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    # lol with doesn't shadow.
    mainProgram = "pik";
  };
}))

