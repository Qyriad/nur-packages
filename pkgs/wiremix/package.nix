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
  version = "0.7.0";

  strictDeps = true;
  __structuredAttrs = true;

  doCheck = true;
  doInstallCheck = true;

  src = fetchFromGitHub {
    owner = "tsowell";
    repo = "wiremix";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-ppYYOonT/JN0w9U4Oh7lLIpoTovcTExZcnw1PeppP5U=";
  };

  cargoDeps = fetchCargoVendor {
    name = lib.suffixName self "cargo-deps";
    inherit (self) src;
    hash = "sha256-KdpWF6WVOJzKvSjCz+XdCSVxd465R8iOK3aFUnSczvU=";
  };

  env.LIBCLANG_PATH = (lib.getLib libclang) + "/lib";

  versionCheckProgramArg = "--version";

  # https://docs.rs/vergen-git2/1.0.7/vergen_git2/index.html#environment-variables
  env.VERGEN_GIT_DESCRIBE = "v${self.version}";

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
