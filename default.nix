{
  pkgs ? import <nixpkgs> { },
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

in discoveredPackages // {
  lib = lib';

  # For exploration purposes.
  nurLib = import ./lib { inherit lib; };

  # For exploration purposes.
  helpers = lib.dontRecurseIntoAttrs {
    inherit (self)
      mkAbsoluteDylibsHook
      fetchGoModules
      goHooks
      rustHooks
    ;
  };

  # For exploration purposes.
  availablePackages = let
    isAvailable = lib'.isAvailableDerivation pkgs.stdenv.hostPlatform;
  in lib.filterAttrs (lib.const isAvailable) discoveredPackages;

  mkAbsoluteDylibsHook = self.callPackage ./helpers/absolute-dylibs.nix { };

  fetchGoModules = self.callPackage ./helpers/fetch-go-modules { };
  goHooks = self.callPackage ./helpers/go-hooks/package.nix { };
  rustHooks = self.callPackage ./helpers/rust-hooks/package.nix { };
})
