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
  nodePackages,
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
  gst_all_1,
  libcanberra-gtk3,
  webkitgtk,
}: let
  inherit (lib) optionalDefault;
  inherit (stdenv) hostPlatform;
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform) optionalLinux optionalDarwin;
  inherit (npmHooks) npmConfigHook npmBuildHook npmInstallHook;
  inherit (nodePackages) npm node-gyp;
  inherit (rustPlatform) importCargoLock cargoSetupHook;
  inherit (gst_all_1) gstreamer gst-vaapi gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad;
  gst-plugins-good' = gst-plugins-good.override {
    gtkSupport = true;
  };

  # Fixes NodeJS running out of JavaScript heap while building on lower-memory machines.
  NODE_OPTIONS = "--max-old-space-size=4096";

  cinny-web = stdenvNoCC.mkDerivation (self: {

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
    # This is needed for cinny-desktop below.
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
  });

in stdenv.mkDerivation (self: {
  pname = "cinny-desktop";
  version = "3.2.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    name = "${self.finalPackage.name}-source";
    owner = "cinnyapp";
    repo = "cinny-desktop";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-++S1QM58ousi9wERE3HNNyqKAI+aNsaNcbTe1G9c+3A=";
  };

  patches = [
    # The preBuild script specified in src-tauri/tauri.conf, expecting to be able to modify the
    # cinny-web directory, unconditionally runs the build commands for cinny-web. We've already
    # built cinny-web, so let's just patch that out.
    ./immutable-cinny-web.patch
  ];

  # npmConfigHook arguments
  env.npmDeps = fetchNpmDeps {
    name = "${self.finalPackage.name}-npm-deps";
    inherit (self) src;
    hash = "sha256-lIUaP9NR+NdOzHwf3BFsuFCzOKKuefuGuN/DILwn+EI=";
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
    if hostPlatform.isLinux then "deb"
    else if hostPlatform.isDarwin then "app"
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
  ] ++ optionalLinux [
    glib-networking
    libayatana-appindicator
    libcanberra-gtk3
    webkitgtk
    gst-plugins-base
    # If other gstreamer stuff is here, this is needed so GLib doesn't assert-fail.
    gst-plugins-good'
    # Needed for playing video attachments with subtitles.
    gst-plugins-bad
  ] ++ optionalDarwin [
    darwin.DarwinTools
    darwin.apple_sdk.frameworks.WebKit
  ];

  cinnyWeb = self.passthru.cinny-web;

  # Replace the empty submodule with a symlink to cinny-web as built above.
  # The Tauri prebuild script normally tries to run `npm run build` in here,
  # but we patched that out above (see patches), so this can be immutable.
  preBuild = ''
    rmdir cinny
    ln -sv "$cinnyWeb/lib/node_modules/cinny" ./
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
  '' + optionalLinux ''
    mv -v "$cargoRoot/target/$rustHostPlatformSpec/release/bundle/deb/"*"/data/usr" "$out"
  '' + optionalDarwin ''
    mkdir -p "$out/Applications"
    cp -r "$cargoRoot/target/$rustHostPlatformSpec/release/bundle/macos/Cinny.app" "$out/Applications/"
    mkdir -p "$out/bin"
    ln -sv "$out/Applications/Cinny.app/Contents/MacOS/Cinny" "$out/bin/cinny";
  '' + ''
    runHook postInstall
  '';

  # These aren't detected by the normal fixup phase and must be added manually.
  runtimeDependencies = optionalLinux [
    libayatana-appindicator
  ];

  # This has to be postFixup (rather than preFixup) or wrapGApps will nullify this.
  postFixup = optionalLinux ''
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
