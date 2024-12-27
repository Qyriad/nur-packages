{
  stdenvNoCC,
  lib,
  go,
  git,
  cacert,
}: ({
  name,
  src,
  hash,
  GO111MODULE ? "on",
  GOTOOLCHAIN ? "local",
  deleteVendor ? false,
}: stdenvNoCC.mkDerivation (self: {
  name = "${name}-go-modules";

  strictDeps = true;
  __structuredAttrs = true;

  inherit src;

  inherit deleteVendor;

  env = {
    inherit (go) GOOS GOARCH;
    inherit GO111MODULE GOTOOLCHAIN;
  };

  nativeBuildInputs = [
    # Sets buildPhase for us.
    ./build-phase.sh
    go
    git
    cacert
  ];

  impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
    "GIT_PROXY_COMMAND"
    "SOCKS_SERVER"
    "GOPROXY"
  ];

  configurePhase = ''
    runHook preConfigure

    export GOCACHE="$TMPDIR/go-cache"
    export GOPATH="$TMPDIR/go"

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    cp -r --reflink=auto vendor "$out"

    runHook postInstall
  '';

  dontFixup = true;

  outputHashMode = "recursive";
  outputHash = hash;
  outputHashAlgo = if self.outputHash == "" then "sha256" else null;
}))
