let
	allowedModes = [
		"pkgs"
		"lib"
	];
in
{
	/** Cursed: allow `import qyriad-nur { mode = "lib"; }` to get merged lib.
	 * This is purely because I'm lazy and `lib // (import (qyriad-nur + "/lib") { inherit lib; })`
	 * is ugly as sin.
	 */
	mode ? "pkgs",

	pkgs ? if mode != "pkgs" then null else (
		import <nixpkgs> {
			config = import ./nixpkgs-config.nix // config;
			inherit overlays;
		}
	),

	overlays ? [ ],
	config ? { },
	lib ? (
		if pkgs != null then (
			pkgs.lib
		) else (
			import <nixpkgs/lib>
		)
	),

}: assert builtins.elem mode allowedModes; if mode == "lib" then (
	lib.extend (final: prev: import ./lib { inherit lib; })
) else let
	# We take `lib` for overlay friendliness.
	# If we are instantiated in a Nixpkgs overlay, then `pkgs` can be `final`,
	# but we MUST have access to a `lib` from `prev` for some specific cases
	# to avoid angering the infinite recursion gods.
	passedLib = lib;

	requireStructuredAttrs = name: drv:
		lib.warnIf (drv.__structuredAttrs or false || drv.allowUnstructuredAttrs or false)
			"missing structuredAttrs for package ${name} (${drv.name}})"
		drv
	;

	requireStrictDeps = name: drv:
		lib.warnIf (drv.strictDeps or false || drv.allowUnstrictDeps or false)
			"missing strictDeps for package ${name} (${drv.name})"
		drv
	;

	seqScopeAvailablePackagesImpl = f: scope: let
		inherit (scope.packages scope) availablePackages;
	in lib.seq (lib.mapAttrs f availablePackages) scope;

	# Overlay-friendliness.
	seqScopeAvailablePackages = if pkgs ? qpkgs then (
			lib.const lib.id
	) else (
		seqScopeAvailablePackagesImpl
	);

in lib.makeScope pkgs.newScope (self: let
	# Make our recursive scope, which contains packages auto-discovered
	# from `./pkgs`, as well as our extended `lib`, meaning those will all be
	# usable in things `callPackage`d in this scope, and, since we're using
	# `pkgs` as our parent scope, things from `pkgs` will also be available in
	# the same way.

	# Pull our scope's `lib`, which contains both `pkgs.lib` as well as our
	# extensions from `./lib`, into this `let` scope, for convenience.
	# The actual place our scope's `lib` comes from is below.
	# Note that this let-binding `lib` shadows `lib ? pkgs.lib` from above.
	inherit (self) lib;

	inherit (self) stdlib validStdenvs;

	# NOTE: this one has to be `passedLib`, not `self.lib`, to not
	# cause infinite recursion.
	# Technically if we're not instantiated in an overlay then it could
	# be `pkgs.lib`, but if `pkgs` is `final` then that too will blow up.
	discoveredPackages = passedLib.packagesFromDirectoryRecursive {
		# Uses `self` as the scope to `callPackage` everything in `./pkgs`.
		#callPackage = p: args: let
		#	base = self.callPackage p args;
		#	# Use the first stdenv in our list that doesn't make the package broken.
		#	preferred = stdlib.pkgByFirstWorkingStdenv self.preferredStdenvs base;
		#in if preferred != null then preferred else base;
		callPackage = self.callPackage;
		directory = ./pkgs;
	}
	|> passedLib.mapDerivationAttrset mkPretty
	|> passedLib.mapAttrs lib.maybeAppendAttrPath;

	mkPretty = pkg: if pkg ? overrideAttrs then stdlib.mkStdenvPretty pkg else pkg;

in discoveredPackages // {

	# Here is where our scope's `lib` actually comes from.
	# It's already in scope as `lib` at this point, thanks to laziness,
	# but this is where it's defined.
	# This is also another case where we must use `prev.lib`.
	lib = passedLib.extend (final: prev: self.nurLib);

	# Same as `lib`, but *only* our additions.
	nurLib = import ./lib { lib = passedLib; };

	/** qpkgs stdlib, in contrast with `lib`, is for functions tied to `pkgs`. */
	stdlib = import ./stdlib {
		qpkgs = self;
		inherit (self) lib;
	};

	# Equivalent to setting `config.fetchedSourceNameDefault` but just for this scope.
	repoRevToNameMaybe = lib.repoRevToName "full";
	# Defined in terms of `repoRevToNameMaybe`.
	fetchFromGitHub = self.callPackage pkgs.fetchFromGitHub.override { };
	# Defined in terms of `fetchFromGitHub`.
	fetchFromGitea = self.callPackage pkgs.fetchFromGitea.override { };
	# TODO: override for other fetchers.

	# For exploration purposes.
	helpers = {
		inherit (self)
			runCommandMinimal
			mkAbsoluteDylibsHook
			fetchGoModules
			goHooks
			rustHooks
			pythonScopes
			validStdenvs
			llvmStdenv
		;
	};

	# For exploration purposes.
	availablePackages = let
		isAvailable = lib.isAvailableDerivation pkgs.stdenv.hostPlatform;
	in discoveredPackages
	|> lib.mapAttrs (_: lib.maybePrependAttrPath "availablePackages")
	|> lib.filterAttrs (lib.const isAvailable);

	/** * An attrset of `pythonXYPackages`-like scopes in Nixpkgs,
	 * (named without the `Packages` part)
	 * including only scopes that successfully evaluate.
	 *
	 * At the time of this writing, that comes out to: pypy310, pypy311, python310,
	 * python311, python312, python313, and python314.
	 */
	pythonScopes = self.lib.cleanCallPackage {
		f = ./helpers/python-scopes.nix;
		scope = self;
	};

	validStdenvs = stdlib.getStdenvs { };
	stdenv = if pkgs.stdenv.hostPlatform.isDarwin then (
		self.validStdenvs.clangStdenv
	) else (
		self.validStdenvs.clangLldStdenv
	);

	/** Our scope's callPackage will try each of these in order that isn't `meta.broken`. */
	preferredStdenvs = [
		validStdenvs.libcxxLldStdenv
		validStdenvs.clangLldStdenv
		validStdenvs.clangStdenv
		validStdenvs.gccStdenv
	];

	runCommandMinimal = self.callPackage ./helpers/run-command-minimal.nix { };
	mkAbsoluteDylibsHook = self.callPackage ./helpers/absolute-dylibs.nix { };

	fetchGoModules = self.callPackage ./helpers/fetch-go-modules { };
	goHooks = self.callPackage ./helpers/go-hooks/package.nix { };
	rustHooks = self.callPackage ./helpers/rust-hooks/package.nix { };
	# Experimental.
	pythonHooks = self.callPackage ./helpers/python-hooks/package.nix { };
})
# Final checks and lints.
|> (scope: lib.deepSeq scope.nurLib scope)
|> seqScopeAvailablePackages requireStructuredAttrs
|> seqScopeAvailablePackages requireStrictDeps
