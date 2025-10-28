{
	lib ? import <nixpkgs/lib>,
	self ? import ./default.nix { inherit lib; },
}:

{
	/** Calls `drv.overrideAttrs f` iff `drv.overrideAttrs` exists.
	 * Otherwise returns `drv` unchanged.
	 */
	maybeOverrideAttrs = f: drv: if ! (drv ? overrideAttrs) then drv else drv.overrideAttrs f;

	maybeOverridePassthru = f: self.maybeOverrideAttrs (final: prev: let
		# Support all three variants of `.overrideAttrs`.
		passthruFp = lib.toExtension f;
	in {
		passthru = prev.passthru or { } // (passthruFp final prev);
	});

	/** Append to a derivation's drv.passthru.attrPath, ignoring anything that
	 * that doesn't have a `.overrideAttrs`, and init-ing empty `attrPath`s if
	 * needed.
	 */
	maybeAppendAttrPath = name: self.maybeOverridePassthru (prev: {
		attrPath = lib.concatLists [
			(prev.passthru.attrPath or [ ])
			[ name ]
		];
	});

	maybePrependAttrPath = name: self.maybeOverridePassthru (prev: {
		attrPath = lib.concatLists [
			[ name ]
			(prev.passthru.attrPath or [ ])
		];
	});

	shouldRecurseIntoAttrs = attrs: (
		if attrs._type or null == "pkgs" then (
			true
		) else if attrs ? overrideScope then (
			attrs.recurseForDerivations or true
		) else (
			attrs.recurseForDerivations or false
		)
	);
}
