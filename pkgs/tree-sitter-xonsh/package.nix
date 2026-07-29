{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	fetchNpmDeps,
	python3Packages,
	pythonHooks,
	npmHooks,
	validatePkgConfig,
	writableTmpDirAsHomeHook,
	nodejs,
	node-gyp,
	tree-sitter,
	cargo,
	rustHooks,
	rustPlatform,
}: lib.callWith' python3Packages ({
	python,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "tree-sitter-xonsh";
	version = "0.2.1";

	outputs = [ "out" "lib" "dev" ];

	src = fetchFromGitHub {
		owner = "FoamScience";
		repo = "tree-sitter-xonsh";
		tag = "v${self.version}";
		hash = "sha256-Hm/gqn+uvec3+HE4bzzxPoRnXcxUFMAkTXQgLnv+xFE=";
		postFetch = ''
			cp -vf "${./package-lock.json}" "$NIX_BUILD_TOP/$sourceRoot/package-lock.json"
		'';
	};

	npmDeps = fetchNpmDeps {
		name = lib.suffixName self "npm-deps";
		inherit (self) src;
		hash = "sha256-PUCbbnhq61s9WFgw/nVW3cgzf/JzholA/SfXjyS+aLI=";
	};

	# Older versions of nix-prefetch-deps weren't compatible with __structuredAttrs.
	postUnpack = lib.optionalString (lib.versionOlder lib.version "26.05") <| lib.dedent ''
		export npmDeps
	'';

	nativeBuildInputs = [
		npmHooks.npmConfigHook
		writableTmpDirAsHomeHook
		validatePkgConfig
		nodejs
		node-gyp
		tree-sitter
	];

	npmRebuildFlags = [
		"--ignore-scripts"
	];

	dontStrip = true;
	keepDebugInfo = true;

	# FIXME: should this be here?
	postConfigure = lib.dedent ''
		tree-sitter generate
	'';

	makeFlags = [
		"PREFIX=${builtins.placeholder "lib"}"
		"PARSER_URL=${self.meta.homepage}"
	] ++ lib.optionals self.dontStrip [
		"STRIP="
	];

	tsOut = (builtins.placeholder "out") + "/lib/tree-sitter/tree-sitter-xonsh";
	dylibExt = stdenv.hostPlatform.extensions.sharedLibrary or stdenv.hostPlatform.extensions.library;

	postInstall = lib.dedent ''
		install -Dm644 "$NIX_BUILD_TOP/$sourceRoot/tree-sitter.json" "$tsOut/tree-sitter.json"
		cp -r "$NIX_BUILD_TOP/$sourceRoot/queries" "$tsOut/queries"
		mkdir -p "$tsOut/parser"
		cp --reflink=auto --dereference "$lib/lib/libtree-sitter-xonsh$dylibExt" "$tsOut/parser/xonsh$dylibExt"
	'';


	# FIXME: add the other bindings.
	# TODO: improve the general way the bindings work. I'm not overly pleased with this one.

	passthru.pythonBindings = stdlib.makePackage stdenv (finalAttrs: {
		pname = "${self.pname}-bindings-python";
		inherit (self) version src npmDeps npmRebuildFlags postUnpack postConfigure;

		outputs = [ "out" "dist" ];

		nativeBuildInputs = lib.concatLists [
			self.nativeBuildInputs
			(pythonHooks python).asList
		];

		propagatedBuildInputs = [
			python3Packages.tree-sitter
		];

		meta = {
			inherit (self.meta) homepage maintainers license sourceProvenance;
			description = "${self.meta.description} (Python bindings)";
		};
	});

	passthru.rustBindings = stdlib.makePackage stdenv (finalAttrs: {
		pname = "${self.pname}-bindings-rust";
		inherit (self) version src npmDeps npmRebuildFlags postUnpack postConfigure;

		replaceFiles."Cargo.lock" = finalAttrs.cargoDeps.lockFile;

		cargoDeps = rustPlatform.importCargoLock {
			lockFile = ./Cargo.lock;
		};

		nativeBuildInputs = lib.concatLists [
			self.nativeBuildInputs
		] ++ [
			# Load-bearing order. Must come before cargoSetupHook.
			stdlib.replaceFilesHook
		] ++ rustHooks.asList ++ [
			cargo
		];

		meta = {
			inherit (self.meta) homepage maintainers license sourceProvenance;
			description = "${self.meta.description} (Rust bindings)";
		};
	});

	meta = {
		homepage = "https://github.com/FoamScience/tree-sitter-xonsh";
		description = "Tree Sitter grammar for xonsh";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		outputsToInstall = [ "out" ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
	};
}))
