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
  pname = "cyme";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "tuna-f1sh";
    repo = "cyme";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-Rq7ykD6L+DrDNz+d++ztv+fmoSSNCoeC1YfXiIJiXzM=";
  };

  cargoDeps = fetchCargoTarball {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-2EIvWipN+ohOo0fGWvRvvnMHpI0YsjZRIrQclFid/XM=";
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
    DarwinTools
  ];

  buildInputs = [
    libusb1
  ] ++ optionalLinux [
    udev
  ] ++ optionalDarwin [
    libiconv
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
    platforms = lib.platforms.darwin ++ (with lib.platforms; linux ++ windows);
    mainProgram = "cyme";
  };
}))
