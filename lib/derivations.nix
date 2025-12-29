{
	lib ? import <nixpkgs/lib>,
	self ? import ./default.nix { inherit lib; },
}: let

	isEnabledDerivation = { ... }@drv: lib.all lib.trivial.id [
		(lib.isDerivation drv)
		(lib.meta.broken or false != true)
		(drv.meta.disabled or false != true)
	];

	/**
		Return true if and only if `drv` is a derivation which is available on the
		given platform and not broken.
	*/
	isAvailableDerivation = hostPlatform: drv: lib.all lib.trivial.id [
		(lib.isDerivation drv)
		(lib.meta.availableOn hostPlatform drv)
		(drv.meta.broken or null != true)
		(drv.meta.disabled or false != true)
	];

	isEvalableDerivation = drv: let
		res = builtins.tryEval (drv.outPath or (throw ""));
	in res.success && lib.isDerivation drv;

	isScope = attrs: lib.all (value: value == true) [
		(lib.isFunction attrs.callPackage or null)
		(lib.isFunction attrs.newScope or null)
		(lib.isFunction attrs.overrideScope or null)
		(lib.isFunction attrs.packages or null)
	];


in {
	inherit
		isEnabledDerivation
		isAvailableDerivation
		isEvalableDerivation
		isScope
	;
}
