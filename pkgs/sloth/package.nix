{
  lib,
  stdenv,
  fetchFromGitHub,
}: stdenv.mkDerivation (self: {
  pname = "sloth";
  version = "2020-09-16-HEAD";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "lunasorcery";
    repo = "sloth";
    rev = "c1c0ee981bbd7464c0c2c03b3ebbe772a2d9444a";
    hash = "sha256-SEyGRtnh48YgjoIeU+iXqMTKUw9SM8wzWZoSau9FQK4=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m 0655 ./bin/sloth "$out/bin/sloth"
    chmod +x "$out/bin/sloth"
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/lunasorcery/sloth";
    description = "Like cat(1), but slower";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "sloth";
  };
})
