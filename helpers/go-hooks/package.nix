{
  lib,
  stdenv,
  makeSetupHook,
  go,
}: lib.recurseIntoAttrs {

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
}
