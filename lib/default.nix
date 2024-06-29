{
  lib ? import <nixpkgs/lib>,
}: let
  /**
    Return true if and only if `drv` is a derivation which is available on the
    given platform and not broken.
  */
  isAvailableDerivation = hostPlatform: drv: lib.all lib.trivial.id [
    (lib.isDerivation drv)
    (lib.meta.availableOn hostPlatform drv)
    (drv.meta.broken or null != true)
  ];

  optionalDefault = cond: valueIfTrue: let
    fnByType = {
      list = lib.optionals;
      set = lib.optionalAttrs;
      string = lib.optionalString;
    };
    valueType = builtins.typeOf valueIfTrue;
    fn = fnByType.${valueType}
      or (throw "no known lib.optional-type function for type: ${valueType}");
  in fn cond valueIfTrue;

in {
  inherit isAvailableDerivation optionalDefault;
}
