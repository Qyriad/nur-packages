{
  lib,
  stdenv,
  fetchFromGitHub,
  darwin,
  rustPlatform,
  cargo,
}: lib.callWith [ darwin rustPlatform ] ({
  libiconv,
  fetchCargoVendor,
  cargoSetupHook,
  cargoBuildHook,
  cargoCheckHook,
  cargoInstallHook,
}: let
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
    optionalDarwin
  ;
in stdenv.mkDerivation (self: {
  pname = "hgrep";
  version = "0.3.7";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rhysd";
    repo = "hgrep";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-3K0Il+2gnOMi3ER652kLBc/COjnUYtVVIv5fe2fX5Xk=";
  };

  cargoBuildType = "release";
  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    inherit (self) src;
    hash = "sha256-jt0Uoo+2g1/sTXfkf7yeRW0tv+iX8OjwMEhqkYcrFag=";
  };

  nativeBuildInputs = [
    cargo
    cargoSetupHook
    cargoBuildHook
    cargoInstallHook
  ];

  doCheck = true;
  cargoCheckType = "test";
  nativeCheckInputs = [
    cargoCheckHook
  ];

  buildInputs = optionalDarwin [
    libiconv
  ];

  meta = {
    homepage = "https://github.com/rhysd/hgrep";
    description = "Grep with human-friendly search results";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    # Seems broken on current Nixpkgs for aarch64-apple-darwin?
    #platforms = lib.attrValues { inherit (lib.platforms) all; };
    mainProgram = "hgrep";
  };
}))
