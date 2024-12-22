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
}: let

  expandBashArray = name: let
    quote = s: ''"${s}"'';

  in quote "\${${name}[@]}";

in stdenvNoCC.mkDerivation (self: {
  name = "${name}-go-modules";

  strictDeps = true;
  __structuredAttrs = true;

  inherit src;

  env = {
    inherit (go) GOOS GOARCH;
    inherit GO111MODULE GOTOOLCHAIN;
  };

  nativeBuildInputs = [
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

  buildPhase = ''
    runHook preBuild
    if [[ -d "vendor" ]]; then
      echo "$name: vendor folder exists, please set 'vendorHash = null;'"
      exit 10
    fi

    go mod vendor ${expandBashArray "goModVendorFlags"};

    mkdir -p vendor

    runHook postBuild
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
