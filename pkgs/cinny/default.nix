{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchNpmDeps,
  cargo,
  rustc,
  nodejs,
  npmHooks,
  python3,
  nodePackages,
}: let
  inherit (npmHooks) npmConfigHook npmBuildHook npmInstallHook;
  inherit (nodePackages) node-gyp;

  cinny-web = stdenvNoCC.mkDerivation (self: {

    pname = "cinny-web";
    version = "3.2.0";

    src = fetchFromGitHub {
      owner = "cinnyapp";
      repo = "cinny";
      rev = "v${self.version}";
      hash = "sha256-wAa7y2mXPkXAfirRSFqwZYIJK0CKDzZG8ULzXzr4zZ4=";
    };

    npmDeps = fetchNpmDeps {
      name = "${self.finalPackage.name}-npm-deps";
      inherit (self) src;
      hash = "sha256-dVdylvclUIHvF5syVumdxkXR4bG1FA4LOYg3GmnNzXE=";
    };

    nativeBuildInputs = [
      npmConfigHook
      npmBuildHook
      npmInstallHook
      python3
    ];

    buildInputs = [
      nodejs
      node-gyp
    ];

    npmRebuildFlags = [
      "--ignore-scripts"
    ];

    npmBuildScript = "build";

    dontNpmPrune = true;
  });

in stdenvNoCC.mkDerivation (self: {
  pname = "cinny-desktop";
  inherit (cinny-web) version;

  src = fetchFromGitHub {
    owner = "cinnyapp";
    repo = "cinny-desktop";
    rev = "v${self.version}";
    hash = "sha256-uHGqvulH7/9JpUjkpcbCh1pPvX4/ndVIKcBXzWmDo+s=";
  };

  npmDeps = fetchNpmDeps {
    name = "${self.finalPackage.name}-npm-deps";
    inherit (self) src;
    hash = "sha256-JLyyZ+CJhyqnC79cKt5XQvjOV1dZb2oYiMSbJYKcX/k=";
  };

  nativeBuildInputs = [
    npmConfigHook
    cargo
    rustc
  ];

  buildInputs = [
    nodejs
  ];

  preBuild = ''
    rmdir cinny
    cp -r ${cinny-web}/lib/node_modules/cinny ./cinny
    chmod u+w -R ./cinny
  '';

  buildPhase = ''
    runHook preBuild
    echo "We are in $(pwd)"
    ls -l --group-directories-first --color=always ./cinny
    npm run tauri build
    runHook postBuild
  '';
})
