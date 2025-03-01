{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchGoModules,
  goHooks,
}: stdenv.mkDerivation (self: {
  pname = "sequin";
  version = "0.3.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "sequin";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-rszK2UZ3Eq9g+Di1lncDQIT4TlUcWZEu1SU2aE2uFHY=";
  };

  goModules = fetchGoModules {
    inherit (self.finalPackage) name;
    inherit (self) src;
    hash = "sha256-mpmGd6liBzz9XPcB00ZhHaQzTid6lURD5I3EvehXsA8=";
  };

  nativeBuildInputs = goHooks.asList;

  passthru = {
    fromHead = lib.mkHeadFetch { self = self.finalPackage; };
  };

  meta = {
    homepage = "https://github.com/charmbracelet/sequin";
    description = "Human-readable ANSI sequences";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    #platforms = lib.attrValues { inherit (lib.platforms) darwin linux windows; };
    mainProgram = "sequin";
  };
})
