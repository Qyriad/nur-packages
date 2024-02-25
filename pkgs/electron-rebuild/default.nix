{
  lib,
  fetchFromGitHub,
  typescript,
  nodePackages,
  mkYarnPackage,
  version ? "3.6.0",
}: mkYarnPackage {
  pname = "electron-rebuild";
  inherit version;

  src = fetchFromGitHub {
    name = "electron-rebuild-source";
    owner = "electron";
    repo = "electron";
    rev = "v${version}";
    hash = "sha256-wiJh1k1lWuz9xrefCwwsZnQIZMtDiW1iHSEdOwmYf2E=";
  };

  nativeBuildInputs = [
    typescript
  ];

  buildPhase = ''
    runHook preBuild
    export HOME="$(mktemp -d)"
    yarn --offline run compile
    runHook postBuild
  '';

  postInstall = ''
    chmod ugo+x $out/bin/electron-rebuild
  '';

  meta = {
    homepage = "https://github.com/electron/rebuild";
    description = "Rebuild native Node.js modules against the currently installed Electron version";
    license = lib.licenses.mit;
    mainProgram = "electron-rebuild";
  };
}
