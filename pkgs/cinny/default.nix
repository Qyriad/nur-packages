{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchNpmDeps,
  python3,
  nodejs,
  npmHooks,
  rust,
  rustPlatform,
  rustc,
  cargo,
  pkg-config,
  gtk3,
  libappindicator,
  libsoup,
  openssl,
  webkitgtk,
}: let
  inherit (npmHooks) npmConfigHook npmBuildHook npmInstallHook;
  inherit (nodejs.pkgs) node-gyp;
  inherit (rustPlatform) importCargoLock cargoSetupHook;

  cinny-web = stdenvNoCC.mkDerivation (self: {

    pname = "cinny-web";
    version = "3.2.0";

    src = fetchFromGitHub {
      owner = "cinnyapp";
      repo = "cinny";
      rev = "v${self.version}";
      hash = "sha256-wAa7y2mXPkXAfirRSFqwZYIJK0CKDzZG8ULzXzr4zZ4=";
    };

    # npmConfigHook arguments.

    npmDeps = fetchNpmDeps {
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
    # This is needed for cinny-desktop below.
    dontNpmPrune = true;

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

    meta = {
      description = "Yet another Matrix client (web)";
      homepage = "https://cinny.in";
      license = lib.licenses.agpl3;
    };
  });

in stdenv.mkDerivation (self: {
  pname = "cinny-desktop";
  inherit (self.passthru.cinny-web) version;

  src = fetchFromGitHub {
    owner = "cinnyapp";
    repo = "cinny-desktop";
    rev = "v${self.version}";
    hash = "sha256-uHGqvulH7/9JpUjkpcbCh1pPvX4/ndVIKcBXzWmDo+s=";
  };

  # npmConfigHook arguments
  npmDeps = fetchNpmDeps {
    name = "${self.finalPackage.name}-npm-deps";
    inherit (self) src;
    hash = "sha256-JLyyZ+CJhyqnC79cKt5XQvjOV1dZb2oYiMSbJYKcX/k=";
  };

  # cargoSetupHook arguments
  cargoRoot = "src-tauri";
  cargoBuildType = "release";
  cargoDeps = importCargoLock {
    lockFile = builtins.path {
      path = self.src + "/src-tauri/Cargo.lock";  name = "Cargo.lock";
    };
  };

  # Normally this would be done by cargoBuildHook. Since we're using tauri
  # to call cargo build, we have to do it ourselves.
  env.rustHostPlatformSpec = rust.envVars.rustHostPlatformSpec;

  nativeBuildInputs = [
    npmConfigHook
    cargoSetupHook
    rustPlatform.cargoInstallHook
    cargo
    rustc
    pkg-config
  ];

  buildInputs = [
    nodejs
    openssl
    gtk3
    libappindicator
    libsoup
    webkitgtk
  ];

  preBuild = ''
    rmdir cinny
    cp -r ${self.passthru.cinny-web}/lib/node_modules/cinny ./cinny
    chmod u+w -R ./cinny
  '';

  # Here we ask Tauri to create a debian bundle,
  # which we'll yoink the files from in installPhase.
  buildPhase = ''
    runHook preBuild
    npm run tauri -- build --verbose --bundles deb --target "$rustHostPlatformSpec"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv -v "$cargoRoot/target/$rustHostPlatformSpec/release/bundle/deb/"*"/data/usr" "$out"
    runHook postInstall
  '';

  passthru = {
    inherit cinny-web;
  };

  meta = {
    mainProgram = "cinny";
    description = "Yet another Matrix client (desktop)";
    homepage = "https://cinny.in";
    license = lib.licenses.agpl3;
  };
})
