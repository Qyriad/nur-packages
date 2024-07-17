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
  # from `./pkgs`, as well as our extended `lib`.
in lib.makeScope pkgs.newScope (self: makePackages self // {
  lib = lib';
})
