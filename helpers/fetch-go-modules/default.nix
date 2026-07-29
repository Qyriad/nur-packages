{
	stdenvNoCC,
	stdlib,
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
	drvAttrs ? { },
}: stdlib.makePackage stdenvNoCC (self: {
	# TODO: We could just suffix it for them.
	# But I don't love the `name =` attribute being silently modified in a derivation constructor...
	name = let
		pname = lib.getName name;
	in (
		lib.warnIfNot
		(lib.strings.hasSuffix "go-modules" pname)
		"fetchGoModules name '${pname}' is unclear and should probably end in 'go-modules'"
		name
	);

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

	configurePhase = lib.dedent ''
		runHook preConfigure

		export GOCACHE="$TMPDIR/go-cache"
		export GOPATH="$TMPDIR/go"

		runHook postConfigure
	'';

	installPhase = lib.dedent ''
		runHook preInstall

		cp -r --reflink=auto vendor "$out"

		runHook postInstall
	'';

	dontFixup = true;

	outputHashMode = "recursive";
	outputHash = hash;
	outputHashAlgo = if self.outputHash == "" then "sha256" else null;
} // drvAttrs))
