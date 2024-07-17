{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  installShellFiles,
  libusb1,
  udev,
  nix-update-script,
  testers,
}: lib.callWith' rustPlatform ({
  importCargoLock,
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
  pname = "cyme";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "tuna-f1sh";
    repo = "cyme";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-iDwH4gSpt1XkwMBj0Ut26c9PpsHcxFrRE6VuBNhpIHk=";
  };

  cargoDeps = importCargoLock {
    lockFile = builtins.path {
      path = self.src + "/Cargo.lock";
      name = "Cargo.lock";
    };
  };
  cargoBuildType = "release";
  cargoBuildFeatures = [
    "libusb"
    "udev"
    "udev_hwdb"
    "cli_generate"
  ];

  nativeBuildInputs = [
    cargoSetupHook
    cargoBuildHook
    cargoCheckHook
    cargoInstallHook
    installShellFiles
    pkg-config
  ] ++ optionalDarwin [
    darwin.DarwinTools
  ];

  buildInputs = [
    libusb1
  ] ++ optionalLinux [
    udev
  ] ++ optionalDarwin [
    darwin.libiconv
  ];

  postInstall = lib.optionalDefault (buildPlatform.canExecute hostPlatform) ''
    "$out/bin/cyme" --gen
    installManPage ./doc/cyme.1

    installShellCompletion --cmd cyme --bash ./doc/cyme.bash
    installShellCompletion --cmd cyme --fish ./doc/cyme.fish
    installShellCompletion --cmd cyme --zsh ./doc/_cyme
    # TODO: where tf do powershell completions go

    install -Dm444 ./doc/cyme_example_config.json --target-directory "$out/share/cyme"
  '';

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = self.finalPackage; };
    fromHead = lib.mkHeadFetch { self = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/tuna-f1sh/cyme";
    description = "Modern cross-platform lsusb";
    longDescription = "List system USB buses and devices; a lib and modern cross-platform lsusb that attempts to maintain compatibility with, but also add new features";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ gpl3Plus ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    # lol with doesn't shadow.
    platforms = with lib.platforms; lib.platforms.darwin ++ linux ++ windows;
    mainProgram = "cyme";
  };
}))
