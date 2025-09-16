{
  pkgs ? import <nixpkgs> { config = import ./nixpkgs-config.nix; },
  lib ? pkgs.lib,
}: let
  # We take `lib` for overlay friendliness.
  # If we are instantiated in a Nixpkgs overlay, then `pkgs` can be `final`,
  # but we MUST have access to a `lib` from `prev` for some specific cases
  # to avoid angering the infinite recursion gods.
  passedLib = lib;
  inherit (builtins) tryEval;

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

  # NOTE: this one has to be `passedLib`, not `self.lib`, to not
  # cause infinite recursion.
  # Technically if we're not instantiated in an overlay then it could
  # be `pkgs.lib`, but if `pkgs` is `final` then that too will blow up.
  discoveredPackages = passedLib.packagesFromDirectoryRecursive {
    # Uses `self` as the scope to `callPackage` everything in `./pkgs`.
    callPackage = self.callPackage;
    directory = ./pkgs;
  };

  # TODO: static?
  validStdenvs = pkgs
  |> lib.filterAttrs (name: _: lib.strings.hasSuffix "Stdenv" name)
  |> lib.filterAttrs (_: stdenv: let
    isStdenv = lib.isAttrs stdenv && stdenv ? mkDerivation;
    canInstantiate = stdenv.outPath != null;
  in lib.tryResOr (tryEval (isStdenv && canInstantiate)) false);

  mkPretty = pkg: if pkg ? overrideAttrs then self.stdlib.mkStdenvPretty pkg else pkg;

in (passedLib.mapDerivationAttrset mkPretty discoveredPackages) // {

  # Here is where our scope's `lib` actually comes from.
  # It's already in scope as `lib` at this point, thanks to laziness,
  # but this is where it's defined.
  # This is also another case where we must use `prev.lib`.
  lib = passedLib // self.nurLib;

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
    ;
  };

  # For exploration purposes.
  availablePackages = let
    isAvailable = lib.isAvailableDerivation pkgs.stdenv.hostPlatform;
  in lib.filterAttrs (lib.const isAvailable) discoveredPackages;

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

  inherit validStdenvs;

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
