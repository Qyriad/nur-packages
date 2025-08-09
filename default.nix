{
  pkgs ? import <nixpkgs> { config = import ./nixpkgs-config.nix; },
  lib ? pkgs.lib,
}: let
  inherit (builtins) tryEval;

  requireStructuredAttrs = name: drv:
    lib.warnIf (drv.__structuredAttrs or false || drv.allowUnstructuredAttrs or false)
      "missing structuredAttrs for package ${name} (${drv.name}})"
    drv
  ;

  seqScopeAvailablePackages = f: scope: let
    inherit (scope.packages scope) availablePackages;
  in lib.seq (lib.mapAttrs f availablePackages) scope;

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

  # NOTE: this one has to be `pkgs.lib`, not `self.lib`, to not
  # cause infinite recursion.
  discoveredPackages = pkgs.lib.packagesFromDirectoryRecursive {
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

in discoveredPackages // {

  # Here is where our scope's `lib` actually comes from.
  # It's already in scope as `lib` at this point, thanks to laziness,
  # but this is where it's defined.
  lib = pkgs.lib // import ./lib { lib = pkgs.lib; };

  # Equivalent to setting `config.fetchedSourceNameDefault` but just for this scope.
  repoRevToNameMaybe = lib.repoRevToName "full";
  # Defined in terms of `repoRevToNameMaybe`.
  fetchFromGitHub = self.callPackage pkgs.fetchFromGitHub.override { };
  # Defined in terms of `fetchFromGitHub`.
  fetchFromGitea = self.callPackage pkgs.fetchFromGitea.override { };
  # TODO: override for other fetchers.

  # For exploration purposes.
  nurLib = import ./lib { inherit lib; };

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
})
# Final checks and lints.
|> (scope: lib.deepSeq scope.nurLib scope)
|> seqScopeAvailablePackages requireStructuredAttrs
