{
  lib,
  stdenv,
  stdenvNoCC,
  darwin,
  makeWrapper,
  wrapGAppsHook,
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
  glib-networking,
  libayatana-appindicator,
  libsoup,
  openssl,
  webkitgtk,
}: let
  inherit (npmHooks) npmConfigHook npmBuildHook npmInstallHook;
  inherit (nodejs.pkgs) node-gyp;
  inherit (rustPlatform) importCargoLock cargoSetupHook;

  NODE_OPTIONS = "--max-old-space-size=4096";

  cinny-web = stdenvNoCC.mkDerivation (self: {

    pname = "cinny-web";
    version = "3.2.0";

    src = fetchFromGitHub {
      name = "cinny-web-source";
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

    env.NODE_OPTIONS = NODE_OPTIONS;

    buildInputs = [
      nodejs
      node-gyp
    ];

    meta = {
      description = "Yet another Matrix client (web)";
      homepage = "https://cinny.in";
      license = lib.licenses.agpl3Only;
    };
  });

in stdenv.mkDerivation (self: {
  pname = "cinny-desktop";
  inherit (self.passthru.cinny-web) version;

  src = fetchFromGitHub {
    name = "cinny-desktop-source";
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
      path = self.src + "/src-tauri/Cargo.lock";
      name = "Cargo.lock";
    };
  };

  # Normally this would be done by cargoBuildHook. Since we're using tauri
  # to call cargo build, we have to do it ourselves.
  env.rustHostPlatformSpec = rust.envVars.rustHostPlatformSpec;

  env.cinnyBundle =
    if stdenv.hostPlatform.isLinux then "deb"
    else if stdenv.hostPlatform.isDarwin then "app"
    else throw "unsupported platform for ${self.finalPackage.name}";

  env.NODE_OPTIONS = NODE_OPTIONS;

  nativeBuildInputs = [
    wrapGAppsHook
    npmConfigHook
    cargoSetupHook
    makeWrapper
    cargo
    rustc
    pkg-config
    nodejs
  ];

  buildInputs = [
    gtk3
    libsoup
    openssl
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libayatana-appindicator
    webkitgtk
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.DarwinTools
    darwin.apple_sdk.frameworks.WebKit
  ];

  # Replace the empty submodule directory with a copy of the above cinny-web derivation's artifacts.
  # This has to be a copy instead of a symlink, because Tauri expects to be able to modify
  # cinny-web's sources, which is also the reason for the chmod.
  preBuild = ''
    rmdir cinny
    cp -r ${self.passthru.cinny-web}/lib/node_modules/cinny ./cinny
    chmod u+w -R ./cinny
  '';

  # On Linux we ask Tauri to create a debian bundle,
  # which we'll yoink the files from in installPhase.
  buildPhase = ''
    runHook preBuild
    npm run tauri -- build --bundles "$cinnyBundle" --target "$rustHostPlatformSpec"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
  '' + lib.optionalString stdenv.hostPlatform.isLinux ''
    mv -v "$cargoRoot/target/$rustHostPlatformSpec/release/bundle/deb/"*"/data/usr" "$out"
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p "$out/Applications"
    mv -v "$cargoRoot/target/$rustHostPlatformSpec/release/bundle/macos/Cinny.app" "$out/Applications/"
    mkdir -p "$out/bin"
    ln -sv "$out/Applications/Cinny.app/Contents/MacOS/Cinny" "$out/bin/cinny";
  '' + ''
    runHook postInstall
  '';

  # These aren't detected by the normal fixup phase and must be added manually.
  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [
    libayatana-appindicator
  ];

  # This has to be postFixup (rather than preFixup) or wrapGApps will nullify this.
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath "${lib.makeLibraryPath self.runtimeDependencies}" "$out/bin/.cinny-wrapped"
  '';

  passthru = {
    inherit cinny-web;
  };

  meta = {
    mainProgram = "cinny";
    description = "Yet another Matrix client (desktop)";
    homepage = "https://cinny.in";
    license = lib.licenses.agpl3Only;
  };
})
