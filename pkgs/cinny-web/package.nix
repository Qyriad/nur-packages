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

  NODE_OPTIONS = "--max-old-space-size=4096";

in stdenvNoCC.mkDerivation (self: {
  pname = "cinny-web";
  version = "3.2.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    name = "cinny-web-source";
    owner = "cinnyapp";
    repo = "cinny";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-wAa7y2mXPkXAfirRSFqwZYIJK0CKDzZG8ULzXzr4zZ4=";
  };

  patches = [
    # Fixes logspam about viteSvgLoader (a hack in the Cinny repo around Vite not supporting inline SVG)
    # not generating a sourcemap for the stuff it modifies.
    ./vite-svg-no-sourcemap.patch
  ];

  # npmConfigHook arguments.

  # npmConfigHook has broken structured attrs support lol.
  env.npmDeps = fetchNpmDeps {
    name = "${self.finalPackage.name}-npm-deps";
    inherit (self) src;
    hash = "sha256-dVdylvclUIHvF5syVumdxkXR4bG1FA4LOYg3GmnNzXE=";
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

  env.NODE_OPTIONS = NODE_OPTIONS;

  postInstall = ''
    # Include vite's artifacts, which are placed in ./dist.
    cp -r ./dist "$out/lib/node_modules/cinny/"
  '';

  meta = {
    description = "Yet another Matrix client (web)";
    homepage = "https://cinny.in";
    license = lib.licenses.agpl3Only;
  };
})
