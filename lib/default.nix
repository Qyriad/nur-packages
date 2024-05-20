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

in {
  inherit isAvailableDerivation;
}
