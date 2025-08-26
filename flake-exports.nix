{
  nixpkgs,
  system,
}: let
  lib = import (nixpkgs + "/lib");

  pkgs = import nixpkgs { inherit system; config = import ./nixpkgs-config.nix; };

  nurScope = import ./default.nix { inherit pkgs; };

  # Get the packages without the scopeyness (.overrideScope, .callPackage, etc).
  nurPackages = nurScope.packages nurScope;

  # Just the user-facing packages, and only ones that are available on this platform.
  packages = nurPackages.availablePackages;

  farm = pkgs.linkFarmFromDrvs "qyriad-nur-all" (lib.attrValues packages);
in {
  inherit pkgs nurPackages packages farm;
}
