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

  /** Takes the result of a `builtins.tryEval` invocation, and a fallback value.
   * If the `tryEval` succeeded, return its value. Otherwise, return `fallback`.
   */
  tryResOr = { success, value }: fallback: if success then value else fallback;

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
  mkPlatformPredicates' = plat: let
    platPredicates = lib.filterAttrs (lib.const startsWith "is") plat;
  in lib.flip lib.mapAttrs' platPredicates (name: value: {
    name = "optional${lib.removePrefix "is" name}";
    value = optionalDefault value;
  });

  mkPlatformPredicates = plat: let
    platPredicates = lib.filterAttrs (lib.const startsWith "is") plat;
  in platPredicates |> lib.mapAttrs' (name: value: {
    name = "optional${lib.removePrefix "is" name}";
    value = optionalDefault value;
  });

  mkPlatformGetters = plat: {
    getLibrary = drv: name:
      "${lib.getLib drv}/lib/lib${name}${plat.extensions.library}";
  };

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

  suffixName = pkg: suffix: "${pkg.pname}-${suffix}-${pkg.version}";

  /** Uses an eval-time impure fetch to attempt to build a package derivation
   * from the latest version of its source. Probably won't work a lot of the time!
   */
  mkHeadFetch = {
    self,
    headRef ? "main",
    extraAttrs ? lib.const { },
  }: self.overrideAttrs (final: prev: extraAttrs final // {
    # We override `name` instead of `version` to not mess up tests.
    name = prev.name or "${final.pname}-${final.version}" + "-HEAD";
    src = fetchTarball (prev.src.override {
      rev = "refs/heads/${headRef}";
    }).url;
  });

  /** Join a list of string-like values with forward slashes. */
  joinPaths = lib.strings.concatStringsSep "/";

  /**
  f: should be a function that accepts two arguments and returns a list to be
  concatenated with the accumulator.
  */
  foldlAttrsToList = f: attrset:
    lib.foldlAttrs (acc: name: value:
      assert lib.isList acc;
      acc ++ (f name value)
    ) [ ] attrset;

  foldlAttrsToList' = lib.flip foldlAttrsToList;

  /** Splat a list as function application arguments. */
  apply = argList: f:
    lib.foldl' (acc: item: acc item) f argList;

  /** Given a function to apply to, splat a list as application arguments. */
  applyTo = f: argList: apply argList f;

  isScope = attrs: lib.all (value: value == true) [
    (lib.isFunction attrs.callPackage or null)
    (lib.isFunction attrs.newScope or null)
    (lib.isFunction attrs.overrideScope or null)
    (lib.isFunction attrs.packages or null)
  ];

in {
  inherit
    isAvailableDerivation
    tryResOr
    optionalDefault
    mkPlatformPredicates
    callWith
    callWith'
    suffixName
    mkHeadFetch
    joinPaths
    mkPlatformGetters
    foldlAttrsToList
    foldlAttrsToList'
    apply
    applyTo
    isScope
  ;
}
