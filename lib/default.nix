{
  lib ? import <nixpkgs/lib>,
}: lib.makeExtensible (self: let
  inherit (builtins) typeOf;

  childExports = [
    ./derivations.nix
    ./fixed-points.nix
  ]
  |> lib.map (file: import file { inherit lib self; })
  |> lib.mergeAttrsList;

in childExports // {
  /** Takes the result of a `builtins.tryEval` invocation, and a fallback value.
   *
   * If the `tryEval` succeeded, return its value. Otherwise, return `fallback`.
   */
  tryResOr = { success, value }: fallback: if success then value else fallback;
  /** Same as `tryResOr` but with opposite argument order. */
  tryResFallback = fallback: { success, value }: if success then value else fallback;

  startsWith = needle: heystack: (lib.match "^(${lib.escapeRegex heystack}).*$") != null;

  optionalDefault = cond: valueIfTrue: let
    fnByType = {
      list = lib.optionals;
      set = lib.optionalAttrs;
      string = lib.optionalString;
    };
    valueType = typeOf valueIfTrue;
    fn = fnByType.${valueType}
      or (throw "no known lib.optional-type function for type: ${valueType}");
  in fn cond valueIfTrue;

  /** Turns every isFoo predicate on a stdenv platform into a partial application of
   * of `optionalDefault`, with a name of the form `optionalFoo`.
   */
  mkPlatformPredicates = plat: let
    # All the `hostPlatform.isLinux`-like attrs.
    platPredicates = lib.filterAttrs (lib.const self.startsWith "is") plat;
  in platPredicates |> lib.mapAttrs' (name: value: {
    name = "optional${lib.removePrefix "is" name}";
    value = self.optionalDefault value;
  });

  mkPlatformGetters = plat: {
    getLibrary = drv: name:
      assert lib.isDerivation drv;
      assert lib.isString name;
      "${lib.getLib drv}/lib/lib${name}${plat.extensions.library}";
    getSharedLibrary = drv: name:
      assert lib.isDerivation drv;
      assert lib.isString name;
      "${lib.getLib drv}/lib/lib${name}${plat.extensions.sharedLibrary}";
    getStaticLibrary = drv: name:
      assert lib.isDerivation drv;
      assert lib.isString name;
      "${lib.getLib drv}/lib/lib${name}${plat.extensions.staticLibrary}";
  };

  importCall = functionOrFile: if lib.isFunction functionOrFile then
    functionOrFile
  else
    import functionOrFile
  ;

  /** Invokes `scope.callPackage f explicitArgs`, but takes a callback
   * to modify the result.
   *
   * - `f` is a `package.nix`-style function (or path to a function), whose
   * call will be hooked.
   *
   * - `scope` is a "scope" attrset, whose `callPackage` attr will be used
   * to hook and call `f`.
   *
   * - `explicitArgs` is an optional attrset used to add or override
   * arguments from `scope`.
   *
   * - `hook` should be a function of the form `hook = f: args: …`.
   * It is called with the same function `scope.callPackage` will call as `f`,
   * and the arguments `scope.callPackage` will pass it as `args`.
   */
  hookCallPackage = {
    f,
    scope,
    explicitArgs ? { },
    hook,
  }: let
    # Create a function that callPackage will inspect as having the same arguments as `f`,
    # but instead of returning what `f` returns, it'll call `hook` with the resolved function
    # and the arguments that `scope.callPackage` would give it, and then return an attrset with
    # `__hookResult` set to the return value of that hook call.
    # After `scope.callPackage mirrored explicitArgs`, we'll get the attrset containing
    # `__hookResult`, which will also have `.override` and `.overrideDerivation`, added
    # by `lib.mkOverrideable`. We extract out `__hookResult` to bypass that mechanism.
    # This is more robust than doing something like `removeAttrs`, since
    # 1) `hook` could return something other than an attrset, and
    # 2) `hook` could return an attrset that already *has* `.override`/`.overrideDerivation`.
    mirrorFrom = self.importCall f;
    applyHook = args: {
      __hookResult = hook mirrorFrom args;
    };
    mirrored = lib.mirrorFunctionArgs mirrorFrom applyHook;
  in (scope.callPackage mirrored explicitArgs).__hookResult;

  /** Gets the "effective arguments" if `f` were called with `scope.callPackage f explicitArgs`. */
  getCallPackageArgs = {
    f,
    scope,
    explicitArgs ? { },
  }: self.hookCallPackage {
    inherit f scope explicitArgs;
    hook = lib.const lib.id;
  };

  /** Calls `scope.callPackage f explicitArgs`, but bypasses `lib.mkOverrideable`.
   * Unlike `autocallWith`, this uses the entire resolution logic from `scope`.
   *
   * That means that `scope` must be a *scope* attrset, with a `callPackage` attr.
   */
  cleanCallPackage = {
    f,
    scope,
    explicitArgs ? { },
  }: self.hookCallPackage {
    inherit f scope explicitArgs;
    hook = lib.id;
  };

  # A reimplementation of lib.callPackageWith tht doesn't lib.mkOverrideable the result.
  autocallWith = import ./autocall-with.nix { inherit lib; };

  # Autocall with no explicit args. Handy for inline destructring.
  callWith' = from: f: self.autocallWith from f { };

  # Autocall with no explicit args, from a list of attrsets.
  # Handy for inline destructuring.
  callWith = fromList: f: let
    foldAttrList = lib.foldl lib.mergeAttrs { };
    finalFrom = foldAttrList fromList;
  in self.callWith' finalFrom f;

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
  joinPaths = list: lib.strings.concatStringsSep "/" list;

  /**
  f: should be a function that accepts two arguments and returns a list to be
  concatenated with the accumulator.
  */
  foldlAttrsToList = f: attrset:
    lib.foldlAttrs (acc: name: value:
      assert lib.isList acc;
      acc ++ (f name value)
    ) [ ] attrset;

  foldlAttrsToList' = lib.flip self.foldlAttrsToList;

  /** Splat a list as function application arguments. */
  splat = argList: f: lib.foldl' (acc: item: acc item) f argList;

  /** Given a function to apply to, splat a list as application arguments. */
  splatTo = f: argList: lib.foldl' (acc: item: acc item) f argList;

  foldToList = list: f: lib.foldl' f [ ] list;

  /** Fallable alternative to <nixpkgs> syntax.
   * Returns the path if found, or null if not.
   */
  tryLookupPath = lookupPath: let
    # This covers both pure evaluation mode and the path not being in nixPath.
    tried = builtins.tryEval (
      builtins.findFile builtins.nixPath lookupPath
    );
  in self.tryResOr tried null;

  /** Fallable alternative to <nixpkgs> syntax.
   * Returns the path if found, or `fallback` if not.
   */
  lookupPathOr = lookupPath: fallback: let
    tried = self.tryLookupPath lookupPath;
  in if tried != null then tried else fallback;

  /** Ensure a flakeref is in its attrset representation, converting a
   * URL-like flakeref to its attrset form if need be.
   */
  explodeFlakeRef = flakeRef: if lib.isStringLike flakeRef then
    builtins.parseFlakeRef (toString flakeRef)
  else if lib.isAttrs flakeRef then
    flakeRef
  else throw "normalizeFlakeRef: invalid argument type ${typeOf flakeRef}";

  /**
   * Shortcut for `builtins.parseFlakeRef` into `builtins.fetchTree`.
   *
   * - `flakeRef` is a flakeref either in URL-like syntax or attrset representation.
   * See `nix3-flake(1)` for what that means.
   */
  fetchFlakeRef = flakeRef: lib.pipe flakeRef [
    self.explodeFlakeRef
    builtins.fetchTree
  ];

  mkOptionalFeaturesDesc = {
    ...
  } @ attrs: attrs
  |> lib.mapAttrsToList (name: value: if value != null then "with ${name}" else "without ${name}")
  |> lib.concatStringsSep (", ");
})
