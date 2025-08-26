{
  lib,
  stdenv,
  darwin,
  makeWrapper,
  wrapGAppsHook3,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs,
  npmHooks,
  rust,
  rustPlatform,
  rustc,
  cargo,
  pkg-config,
  cinny-web,
  gtk3,
  glib-networking,
  libayatana-appindicator,
  libsoup ? throw "neither libsoup nor libsoup_2_4 exist",
  libsoup_2_4 ? libsoup,
  openssl,
  gst_all_1,
  libcanberra-gtk3,
  webkitgtk_4_0,
}: let
  inherit (stdenv) hostPlatform;
  inherit (lib.mkPlatformPredicates stdenv.hostPlatform) optionalLinux optionalDarwin;
  inherit (npmHooks) npmConfigHook;
  inherit (rustPlatform) fetchCargoVendor cargoSetupHook;
  inherit (gst_all_1) gst-plugins-base gst-plugins-good gst-plugins-bad;
  gst-plugins-good' = gst-plugins-good.override {
    gtkSupport = true;
  };

  # Fixes NodeJS running out of JavaScript heap while building on lower-memory machines.
  NODE_OPTIONS = "--max-old-space-size=4096";

in stdenv.mkDerivation (self: {
  pname = "cinny-desktop";
  version = "4.3.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    name = "${self.finalPackage.name}-source";
    owner = "cinnyapp";
    repo = "cinny-desktop";
    rev = "refs/tags/v${self.version}";
    hash = "sha256-lVBKzajxsQ33zC6NhRLMbWK81GxCbIQPtSR61yJHUL4=";
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
    hash = "sha256-jd7iPwfW35M03mIgH+v5xlZ45shzBQQR99Vy+gKSVp8=";
  };

  # cargoSetupHook arguments
  cargoRoot = "src-tauri";
  cargoBuildType = "release";
  cargoDeps = fetchCargoVendor {
    name = "${self.finalPackage.name}-cargo-deps";
    src = lib.joinPaths [ self.src "src-tauri" ];
    hash = "sha256-a2IyJ5a11cxgHpb2WRDxVF+aoL8kNnjBNwaQpgT3goo=";
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
    wrapGAppsHook3
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
    libsoup_2_4
    openssl
  ] ++ optionalLinux [
    glib-networking
    libayatana-appindicator
    libcanberra-gtk3
    webkitgtk_4_0
    gst-plugins-base
    # If other gstreamer stuff is here, this is needed so GLib doesn't assert-fail.
    gst-plugins-good'
    # Needed for playing video attachments with subtitles.
    gst-plugins-bad
  ];

  cinnyWeb = self.passthru.cinny-web;

  # Replace the empty submodule with a symlink to cinny-web as built above.
  # The Tauri prebuild script normally tries to run `npm run build` in here,
  # but we patched that out above (see patches), so this can be immutable.
  preBuild = ''
    rmdir cinny
    #ln -sv "$cinnyWeb/lib/node_modules/cinny" ./
    cp -r "$cinnyWeb/lib/node_modules/cinny" ./
    chmod +w cinny
    ln -svrf ./config.json ./cinny/config.json
  '';

  # On Linux we ask Tauri to create a debian bundle,
  # which we'll yoink the files from in installPhase.
  buildPhase = ''
    runHook preBuild
    export PATH="$PWD/node_modules/.bin:$PATH"
    tauri build --bundles "$cinnyBundle" --target "$rustHostPlatformSpec"
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

    wrapProgram "$out/bin/cinny" \
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
  '';

  passthru = {
    inherit cinny-web;
  };

  meta = {
    mainProgram = "cinny";
    description = "Yet another Matrix client (desktop)";
    homepage = "https://cinny.in";
    changelog = "https://github.com/cinnyapp/cinny-desktop/releases/tag/v${self.version}";
    license = lib.licenses.agpl3Only;
  };
})
