{
  pkgs ? import <nixpkgs> { config = import ./nixpkgs-config.nix; },
  lib ? pkgs.lib,
}: lib.makeScope pkgs.newScope (self: let
  # Make our recursive scope, which contains packages auto-discovered
  # from `./pkgs`, as well as our extended `lib`, meaning those will all be
  # usable in things `callPackage`d in this scope, and, since we're using
  # `pkgs` as our parent scope, things from `pkgs` will also be available in
  # the same way.

  lib' = lib // import ./lib { inherit lib; };

  # Uses `self` as the scope to `callPackage` everything in `./pkgs`.
  discoveredPackages = lib.packagesFromDirectoryRecursive {
    callPackage = self.callPackage;
    directory = ./pkgs;
  };

  # TODO: static?
  validStdenvs = pkgs
  |> lib.filterAttrs (name: _: lib.strings.hasSuffix "Stdenv" name)
  |> lib.filterAttrs (_: stdenv: let
    isStdenv = lib.isAttrs stdenv && stdenv ? mkDerivation;
    canInstantiate = stdenv.outPath != null;
  in lib'.tryResOr (builtins.tryEval (isStdenv && canInstantiate)) false);

in discoveredPackages // {
  lib = lib';

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
    isAvailable = lib'.isAvailableDerivation pkgs.stdenv.hostPlatform;
  in lib.filterAttrs (lib.const isAvailable) discoveredPackages;

  /** * An attrset of `pythonXYPackages`-like scopes in Nixpkgs,
   * (named without the `Packages` part)
   * including only scopes that successfully evaluate.
   *
   * At the time of this writing, that comes out to: pypy310, pypy311, python310,
   * python311, python312, python313, and python314.
   */
  pythonScopes = _: pkgs.pythonInterpreters
  |> lib.filterAttrs (name: _: lib.hasAttr "${name}Packages" pkgs)
  |> lib.filterAttrs (_: py: lib'.tryResOr (tryEval (lib.isDerivation py)) false)
  |> lib.filterAttrs (_: py: lib'.tryResOr (tryEval py.isPy3) false)
  |> lib.mapAttrs (pyAttr: python: pkgs."${pyAttr}Packages");

  inherit validStdenvs;

  mkAbsoluteDylibsHook = self.callPackage ./helpers/absolute-dylibs.nix { };

  fetchGoModules = self.callPackage ./helpers/fetch-go-modules { };
  goHooks = self.callPackage ./helpers/go-hooks/package.nix { };
  rustHooks = self.callPackage ./helpers/rust-hooks/package.nix { };
})
