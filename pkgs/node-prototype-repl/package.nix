{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs,
  nodePackages,
  npmHooks,
}: lib.callWith [ npmHooks nodePackages ] ({
  npmConfigHook,
  npmBuildHook,
  npmInstallHook,
}: let
  stdenv = stdenvNoCC;
in stdenv.mkDerivation (self: {
  pname = "node-prototype-repl";
  version = "2023-03-09-de2f7e7";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    name = "${self.pname}-source-${self.version}";
    owner = "nodejs";
    repo = "repl";
    rev = "de2f7e7ffadcf709961d3c7fb5ab96029de0d26b";
    hash = "sha256-dOz0+sL6i6QiKX3cRqpBXnFfSqeqoZSfF6GvYDbkupU=";
  };

  prePatch = ''
    cp -v "$npmDeps/package-lock.json" ./package-lock.json
  '';


  # npmConfigHook has broken structurred attrs support lol
  env.npmDeps = fetchNpmDeps {
    name = "${self.pname}-npm-deps-${self.version}";
    inherit (self) src;
    hash = "sha256-1NU5wUiG4DHf9Sy90LnGIBrOrWUht/bUOyX+94gtusU=";

    packageLockJson = ./package-lock.json;

    postPatch = ''
      cp -v "$packageLockJson" ./package-lock.json
    '';
  };

  dontNpmBuild = true;
  dontNpmPrune = true;

  nativeBuildInputs = [
    nodejs
    npmConfigHook
    npmBuildHook
    npmInstallHook
  ];

  meta = {
    homepage = "https://github.com/nodejs/repl";
    description = "Prototype for an improved NodeJS REPL";
    maintainers = with lib.maintainers; [ qyriad ];
    license = with lib.licenses; [ mit ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "node-prototype-repl";
  };
}))
