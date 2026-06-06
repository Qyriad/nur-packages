{
	lib ? import <nixpkgs/lib>,
	self ? import ./default.nix { inherit lib; },
}:

{
	rust = {
		/** https://doc.rust-lang.org/nightly/edition-guide/rust-2024/index.html#rust-2024 */
		edition2024 = "1.85.0";
	};
}
