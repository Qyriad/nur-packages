{
  lib,
  newScope,
  makeSetupHook,
  rustPlatform,
}: lib.recurseIntoAttrs (lib.makeScope newScope (self: {
  # FIXME: does that lib.recurseIntoAttrs do anything?

  # Allow the rustPlatform used to make and re-export these hooks to be accessed as
  # `rustHooks.rustPlatform`.
  inherit rustPlatform;

  # Abuse some laziness so you can add `nativeBuildInputs = rustHooks.asList` to conveniently
  # allow all the Rust hooks at once.
  asList = [
    # We repeat `self.` instead of the `attrValues` trick to preserve hook order.
    # It *probably* doesn't matter, but just to be on the safe side...
    self.cargoDefaultsHook
    self.cargoSetupHook
    self.cargoBuildHook
    self.cargoCheckHook
    self.cargoInstallHook
  ];

  /**
    Arguments:
      dontSetCargoDefaults: set to non-empty to not set cargoBuildType=release
      and cargoCheckType=test
  */
  cargoDefaultsHook = makeSetupHook {
    name = "cargo-defaults-hook";
  } ./cargo-defaults-hook.sh;

  inherit (rustPlatform)
    cargoSetupHook
    cargoBuildHook
    cargoCheckHook
    cargoInstallHook
  ;
}))
