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

  startsWith = needle: heystack: (lib.match "^(${lib.escapeRegex heystack}).*$") != null;

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

  /** Turns every isFoo predicate on a stdenv platform into a partial application of
   * of `optionalDefault`, with a name of the form `optionalFoo`.
   */
  mkPlatformPredicates = plat: let
    platPredicates = lib.filterAttrs (lib.const startsWith "is") plat;
  in lib.flip lib.mapAttrs' platPredicates (name: value: {
    name = "optional${lib.removePrefix "is" name}";
    value = optionalDefault value;
  });

  # A reimplementation of lib.callPackageWith tht doesn't lib.mkOverrideable the result.
  autocallWith = import ./autocall-with.nix { inherit lib; };

  # Autocall with no explicit args. Handy for inline destructring.
  callWith' = from: f: autocallWith from f { };

  # Autocall with no explicit args, from a list of attrsets.
  # Handy for inline destructuring.
  callWith = fromList: f: let
    foldAttrList = lib.foldl lib.mergeAttrs { };
    finalFrom = foldAttrList fromList;
  in callWith' finalFrom f;

  /** Uses an eval-time impure fetch to attempt to build a package derivation
   * from the latest version of its source. Probably won't work a lot of the time!
   */
  mkHeadFetch = {
    self,
    headRef ? "main",
  }: self.overrideAttrs (prev: {
    version = prev.version + "-HEAD";
    src = fetchTarball (prev.src.override {
      rev = "refs/heads/${headRef}";
    }).url;
  });

  /** Join a list of string-like values with forward slashes. */
  joinPaths = lib.strings.concatStringsSep "/";

in {
  inherit isAvailableDerivation optionalDefault mkPlatformPredicates callWith callWith' mkHeadFetch joinPaths;
}
