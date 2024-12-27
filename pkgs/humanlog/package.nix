{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchGoModules,
  goHooks,
}: stdenv.mkDerivation (self: {
  pname = "humanlog";
  version = "0.7.8";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "humanlogio";
    repo = "humanlog";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-c2OsSzLSp1NYTk6nGX4H5QdDVUuSlCKO/w+ST+2lptE=";
  };

  goModules = fetchGoModules {
    inherit (self.finalPackage) name;
    inherit (self) src;
    hash = "sha256-9EDcWrbRK2+kYBQ2A10Q6d72bAPO4sV1RWj98+wNdGw=";

    # There's an existing vendor directory, but we're doing our own vendoring.
    deleteVendor = true;
  };

  nativeBuildInputs = goHooks.asList;

  meta = {
    homepage = "https://github.com/humanlogio/humanlog";
    description = "Logs for humans to read";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvanence = with lib.sourceTypes; [ fromSource ];
    mainProgram = "humanlog";
  };
})
