{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:

let

  # Uses `self` as the scope to `callPackage` everything in `./pkgs`.
  makePackages = self: lib.packagesFromDirectoryRecursive {
    callPackage = self.callPackage;
    directory = ./pkgs;
  };

  lib' = lib.extend (final: prev: import ./lib {
    lib = final;
  });

  # Finally, make our recursive scope, which contains packages auto-discovered
  # from `./pkgs`, as well as our extended `lib`, meaning those will all be
  # usable in things `callPackage`d in this scope, and, since we're using
  # `pkgs` as our parent scope, things from `pkgs` will also be available in
  # the same way.
in lib.makeScope pkgs.newScope (self: makePackages self // {
  lib = lib';

  mkAbsoluteDylibsHook = self.callPackage ./helpers/absolute-dylibs.nix { };
})
