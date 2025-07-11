{
  lib,
  clangStdenv,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  rustHooks,
  cargo,
  libclang,
  pipewire,
  versionCheckHook,
}: lib.callWith' rustPlatform ({
  fetchCargoVendor,
  importCargoLock,
}: let
  # There seem to be bindgen issues trying to mix GCC and Clang,
  # so let's just use Clang.
  stdenv = clangStdenv;
in stdenv.mkDerivation (self: {
  pname = "wiremix";
  version = "0.5.0";

  strictDeps = true;
  __structuredAttrs = true;

  doCheck = true;
  doInstallCheck = true;

  src = fetchFromGitHub {
    owner = "tsowell";
    repo = "wiremix";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-pEsN7GBPExf/zsCNzzSYjkyGDyOioWmpDFgJkYbrXMI=";
  };

  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.pname}-cargo-deps-${self.finalPackage.version}";
    inherit (self) src;
    hash = "sha256-czhPbXkhuwUdwwP2uizU1Ob8t/x0nrJr3rquRO8Zktw=";
  };

  env.LIBCLANG_PATH = (lib.getLib libclang) + "/lib";

  versionCheckProgramArg = "--version";

  nativeBuildInputs = rustHooks.asList ++ [
    cargo
    pkg-config
  ];

  buildInputs = [
    pipewire
    libclang
  ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

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
    homepage = "https://github.com/tsowell/wiremix";
    description = "A simple TUI mixer for PipeWire";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ asl20 mit ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
    mainProgram = "wiremix";
  };
}))
