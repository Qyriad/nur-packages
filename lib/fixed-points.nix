{
	lib ? import <nixpkgs/lib>,
	self ? import ./default.nix { inherit lib; },
}: let

	isFixedPointAttrs = self:
		lib.isFunction self
		&& lib.isAttrs (lib.fix self)
	;

	/** Essentially the same as lib.extends, but with a better name,
	 * and more flexible `overlay` argument.
	 */
	applyOverlay = overlay: fpAttrs: let
		# Allow `overlay` to be passed as a normal attrset for convenience.
		overlay' = lib.toExtension overlay;
	in lib.extends overlay' fpAttrs;
in {
	inherit
		applyOverlay
	;
}
