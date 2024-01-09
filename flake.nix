{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;

        nurPackages = import ./default.nix {
          inherit pkgs;
        };

      in {
        packages = lib.filterAttrs (name: value: lib.isDerivation value) nurPackages;
      }

    ) # eachDefaultSystem

  ;# outputs
}
