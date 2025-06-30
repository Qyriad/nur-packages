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
  fetchCargoVendor,
  importCargoLock,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "obs-cmd";
  version = "0.18.4";

  strictDeps = true;
  __structuredAttrs = true;
  doCheck = true;

  src = fetchFromGitHub {
    owner = "grigio";
    repo = "obs-cmd";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-/LgQqxZqxbE8hgip+yl8VVjiRYD+6AblKag2MQo1gDs=";
  };

  cargoDeps = fetchCargoVendor {
    name = lib.suffixName self "cargo-deps";
    inherit (self) src;
    hash = "sha256-ZKHm6N7y5FbDFiK2QfQ+9siexgzrdLpBs5Xikh1SRLo=";
  };

  nativeBuildInputs = rustHooks.asList ++ [
    cargo
  ];

  buildInputs = optionalDarwin [
    libiconv
  ];

  passthru.tests.version = testers.testVersion { package = self.finalPackage; };
  passthru.fromHead = lib.mkHeadFetch {
    self = self.finalPackage;
    headRef = "master";
    extraAttrs = self: {
      cargoDeps = importCargoLock {
        lockFile = self.src + "/Cargo.lock";
        allowBuiltinFetchGit = true;
      };
    };
  };

  meta = {
    homepage = "https://github.com/grigio/obs-cmd";
    description = "An OBS cli for obs-websocket v5 the current obs-studio implementation";
    longDescription = ''
      An OBS cli for obs-websocket v5 the current obs-studio implementation. It is useful on Wayland Linux or to control OBS via terminal
    '';
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "obs-cmd";
  };
}))
