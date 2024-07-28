{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs,
  nodePackages,
  npmHooks,
  python3,
}: let
  inherit (npmHooks) npmConfigHook npmBuildHook npmInstallHook;
  inherit (nodePackages) npm node-gyp;

in stdenvNoCC.mkDerivation (self: {
  pname = "cinny-web";
  version = "4.0.3";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    name = "cinny-web-source";
    owner = "cinnyapp";
    repo = "cinny";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-5Tf1CgB/YAyGVpopHERQ8xNGwklB+f2l+yfgCKsR3I8=";
  };

  # npmConfigHook arguments.

  # npmConfigHook has broken structured attrs support lol.
  env.npmDeps = fetchNpmDeps {
    name = "${self.finalPackage.name}-npm-deps";
    inherit (self) src;
    hash = "sha256-wtHFqnz5BtMUikdFZyTiLrw+e69WErowYBhu8cnEjkI=";
  };

  npmRebuildFlags = [
    "--ignore-scripts"
  ];

  # npmBuildHook arguments.

  npmBuildScript = "build";

  # npmInstallHook arguments.

  # Needed for cinny-desktop.
  dontNpmPrune = true;

  nativeBuildInputs = [
    nodejs
    node-gyp
    npm
    npmConfigHook
    npmBuildHook
    npmInstallHook
    python3
  ];

  env.NODE_OPTIONS = "--max-old-space-size=4096";

  postInstall = ''
    # Include vite's artifacts, which are placed in ./dist.
    cp -r ./dist "$out/lib/node_modules/cinny/"
  '';

  meta = {
    description = "Yet another Matrix client (web)";
    homepage = "https://cinny.in";
    changelog = "https://github.com/cinnyapp/cinny/releases/tag/v${self.version}";
    license = lib.licenses.agpl3Only;
  };
})
