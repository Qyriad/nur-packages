{
  pkgs ? import <nixpkgs> { config = import ./nixpkgs-config.nix; },
  lib ? pkgs.lib,
}: lib.makeScope pkgs.newScope (self: let
  # Make our recursive scope, which contains packages auto-discovered
  # from `./pkgs`, as well as our extended `lib`, meaning those will all be
  # usable in things `callPackage`d in this scope, and, since we're using
  # `pkgs` as our parent scope, things from `pkgs` will also be available in
  # the same way.

  lib' = lib.extend (final: prev: import ./lib {
    lib = final;
  });

  # Uses `self` as the scope to `callPackage` everything in `./pkgs`.
  discoveredPackages = lib.packagesFromDirectoryRecursive {
    callPackage = self.callPackage;
    directory = ./pkgs;
  };

  pythonScopes = pkgs.pythonInterpreters
  |> lib.filterAttrs (name: python: let
    res = builtins.tryEval (lib.isDerivation python && python.isPy3);
    hasScope = lib.hasAttr "${name}Packages" pkgs;
  in (lib'.tryResOr res false) && hasScope)
  |> lib.mapAttrs (pyAttr: python: pkgs."${pyAttr}Packages");

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

  inherit pythonScopes;
  inherit validStdenvs;

  mkAbsoluteDylibsHook = self.callPackage ./helpers/absolute-dylibs.nix { };

  fetchGoModules = self.callPackage ./helpers/fetch-go-modules { };
  goHooks = self.callPackage ./helpers/go-hooks/package.nix { };
  rustHooks = self.callPackage ./helpers/rust-hooks/package.nix { };
})
