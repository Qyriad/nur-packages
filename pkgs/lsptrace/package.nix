{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchGoModules,
  goHooks,
}: stdenv.mkDerivation (self: {
  pname = "lsptrace";
  version = "2024-12-05-34daa52";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "mparq";
    repo = "lsptrace";
    rev = "34daa521cd53d807518d9479ac6c8bcea95994d1";
    hash = "sha256-As/PdPBidG09DOaXGJUBPW5wCbKUQfOPL2Cm/HS2nGg=";
  };

  goModules = fetchGoModules {
    name = lib.suffixName self "go-modules";
    inherit (self) src;
    hash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
    drvAttrs.sourceRoot = self.sourceRoot;
  };

  sourceRoot = self.src.name + "/lsptrace";

  nativeBuildInputs = goHooks.asList;

  meta = {
    homepage = "https://github.com/mparq/lsptrace";
    description = "Parses lsp traffic into traces for easy analysis of the lsp protocol";
    maintainers = with lib.maintainers; [ qyriad ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "lsptrace";
  };
})
