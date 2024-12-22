{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchGoModules,
  go,
  goHooks,
}: lib.callWith' goHooks ({
  goConfigureHook,
  goBuildHook,
  goInstallHook,
}: stdenv.mkDerivation (self: {
  pname = "sequin";
  version = "0.3.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "sequin";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-pGZ7QmmPIpXrRcfkbEbTZzHXHtqPwU8Cju9Q2xtSqvw=";
  };

  goModules = fetchGoModules {
    inherit (self.finalPackage) name;
    inherit (self) src;
    hash = "sha256-LehOqSahbF3Nqm0/bJ0Q3mR0ds8FEXaLEvGLwzPdvU4=";
  };

  nativeBuildInputs = [
    go
    goConfigureHook
    goBuildHook
    goInstallHook
  ];

  passthru = {
    fromHEad = lib.mkHeadFetch { self = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/charmbracelet/sequin";
    description = "Human-readable ANSI sequences";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    platforms = lib.attrValues { inherit (lib.platforms) darwin linux windows; };
    mainProgram = "sequin";
  };
}))
