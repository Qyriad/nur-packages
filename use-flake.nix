# Same as importing ./default.nix { } but using Nixpkgs from flake.lock.
let
	flake = builtins.getFlake (toString ./.);
	pkgs = import flake.inputs.nixpkgs {
		config = import ./nixpkgs-config.nix;
	};
in import ./default.nix { inherit pkgs; }
