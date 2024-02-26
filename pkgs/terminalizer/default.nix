{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildNpmPackage,
  fetchNpmDeps,
  nodePackages,
  electron,
  typescript,
  electron-rebuild,
  wrapperArgs ? lib.strings.escapeShellArgs [
    "--set" "ELECTRON_OVERRIDE_DIST_PATH" "${electron}/bin"
  ],
  version ? "0.11.0",
}: let

  patchedSources = stdenvNoCC.mkDerivation {
    name = "terminalizer-${version}-patched-sources.tar.gz";
    src = fetchFromGitHub {
      owner = "faressoft";
      repo = "terminalizer";
      rev = "v${version}";
      hash = "sha256-+62OM7pVtBRpeniO4e3X41R8nnk95Dk1EUL3HEEIZe4=";
    };

    patches = [
      ./fix-package-lock.patch
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      tar -czvf "$out" *
    '';
  };

  terminalizer = buildNpmPackage {
    pname = "terminalizer";
    inherit version;

    src = patchedSources;

    sourceRoot = "./";

    nativeBuildInputs = [
      nodePackages.node-gyp
      electron
      electron-rebuild
    ];

    buildInputs = [
      electron
    ];

    npmFlags = [ "--ignore-scripts" ];

    npmDeps = fetchNpmDeps {
      name = "terminalizer-node-deps";
      src = patchedSources;
      hash = "sha256-Fc2Lae5Q6Jmz/N7m+1Kkx+3eeDAG9R8bH1PB+2pjYME=";
      sourceRoot = "./";
    };

    preBuild = ''
      electron-rebuild -f -w node-pty
    '';

    postInstall = ''
      wrapProgram $out/bin/terminalizer ${wrapperArgs}
    '';

    meta = {
      mainProgram = "terminalizer";
    };

    passthru = {
      inherit patchedSources;
      originalSources = patchedSources.src;
    };
  };
in
  terminalizer
