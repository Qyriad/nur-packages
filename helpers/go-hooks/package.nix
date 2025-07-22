{
  lib,
  # We make a new scope so we can abuse some laziness.
  # See `asList` below.
  newScope,
  stdenv,
  makeSetupHook,
  go,
}: lib.recurseIntoAttrs (lib.makeScope newScope (self: {
  # FIXME: does that lib.recurseIntoAttrs do anyting?

  # Allow the stdenv and go derivations used to make these hooks to be accessed
  # as `goHooks.stdenv` and `goHooks.go`.
  inherit stdenv go;

  # Abuse some laziness so you can add `nativeBuildInputs = goHooks.asList` to conveniently
  # apply all the Go hooks at once.
  asList = [
    # We repeat `self.` instead of the `attrValues` trick to preserve hook order.
    # It *probably* doesn't matter, but just to be on the safe side...
    self.goConfigureHook
    self.goBuildHook
    self.goInstallHook
  ];

  goConfigureHook = makeSetupHook {
    name = "go-configure-hook-${go.name}-${stdenv.name}";

    propagatedBuildInputs = [
      go
    ];

    substitutions = {
      # Remember: `toString` is shell-brained.
      hostAndBuildPlatformsDiffer = toString (stdenv.hostPlatform != stdenv.buildPlatform);
      inherit (go) GOOS GOARCH;
    };
  } ./go-configure-hook.sh;

  goBuildHook = makeSetupHook {
    name = "go-build-hook-${go.name}-${stdenv.name}";

    propagatedBuildInputs = [
      go
    ];
  } ./go-build-hook.sh;

  goInstallHook = makeSetupHook {
    name = "go-install-hook-${go.name}-${stdenv.name}";

  } ./go-install-hook.sh;
}))
