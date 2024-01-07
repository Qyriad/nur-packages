{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs { inherit system; };

        nurPackages = import ./default.nix {
          inherit pkgs;
        };

      in {
        packages = {
          inherit (nurPackages)
            python-pipe
            xontrib-abbrevs
            xonsh-direnv
          ;
        };
      }

    ) # eachDefaultSystem

  ;# outputs
}
