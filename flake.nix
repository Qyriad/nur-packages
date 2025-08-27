{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      flake = false;
    };
    nixpkgs-25_05 = {
      url = "github:NixOS/nixpkgs/release-25.05";
      flake = false;
    };
    nixpkgs-24_11 = {
      url = "github:NixOS/nixpkgs/release-24.11";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-25_05,
    nixpkgs-24_11,
  }: let
    lib = import (nixpkgs + "/lib");
    nurLib = import ./lib { inherit lib; };
    inherit (lib.systems) flakeExposed;
    forAllSystems = lib.genAttrs flakeExposed;

    genForNixpkgs = system: nixpkgs: let
      pkgs = import nixpkgs { inherit system; config = import ./nixpkgs-config.nix; };
      nurScope = import ./default.nix { inherit pkgs; };

      # Get the packages without the scopeyness (.overrideScope, .callPackage, etc).
      nurPackages = nurScope.packages nurScope;

      # Just the user-facing packages, and only ones that are available on this platform.
      packages = nurPackages.availablePackages;

      farm = pkgs.linkFarmFromDrvs "qyriad-nur-all" (lib.attrValues packages);
    in {
      inherit nurPackages farm;
      packages = packages // {
        default = farm;
      };
    };

  in {
    # Export our 'nurLib' as a system-independent output.
    lib = nurLib;

    packages = forAllSystems (system: (genForNixpkgs system nixpkgs).packages);

    # Everything, from user-facing packages to hooks to functions.
    legacyPackages = forAllSystems (system: (genForNixpkgs system nixpkgs).nurPackages);

    checks = forAllSystems (system: {
      packages = self.packages.${system}.default;
      nixpkgs-25_05 = (genForNixpkgs system nixpkgs-25_05).farm;
      nixpkgs-24_11 = (genForNixpkgs system nixpkgs-24_11).farm;
    });
  };
}
