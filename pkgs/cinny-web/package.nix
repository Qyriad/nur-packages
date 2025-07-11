{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs,
  node-gyp,
  npmHooks,
  python3,
}: let
  inherit (npmHooks) npmConfigHook npmBuildHook npmInstallHook;

in stdenvNoCC.mkDerivation (self: {
  pname = "cinny-web";
  version = "4.3.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    name = "cinny-web-source";
    owner = "cinnyapp";
    repo = "cinny";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-cRsjzIq8uFipyYYmxK4JzmG3Ba/0NaScyiebGqoZJFE=";
  };

  # npmConfigHook arguments.

  # npmConfigHook has broken structured attrs support lol.
  env.npmDeps = fetchNpmDeps {
    name = "${self.finalPackage.name}-npm-deps";
    inherit (self) src;
    hash = "sha256-ZmeXZN9sW17y4aIeIthvs4YiFF77xabeVXGwr6O49lQ=";
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
